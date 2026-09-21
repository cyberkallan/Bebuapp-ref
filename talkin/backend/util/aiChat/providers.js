// OpenAI-compatible chat completion client with ordered failover.
//
// Every free provider worth using (Groq, Gemini via its OpenAI endpoint,
// OpenRouter, Cerebras, Mistral, self-hosted Ollama) speaks the same
// /chat/completions shape, so one client covers all of them.

const PRESETS = {
  groq: {
    label: "Groq",
    baseUrl: "https://api.groq.com/openai/v1",
    model: "llama-3.3-70b-versatile",
    models: ["llama-3.3-70b-versatile", "llama-3.1-8b-instant", "meta-llama/llama-4-scout-17b-16e-instruct", "openai/gpt-oss-120b", "qwen/qwen3-32b"],
    keyUrl: "https://console.groq.com/keys",
    freeTier: "No card. ~30 req/min; 1,000 req/day on 70B, 14,400/day on 8B. Fastest responses.",
  },
  gemini: {
    label: "Google Gemini",
    baseUrl: "https://generativelanguage.googleapis.com/v1beta/openai",
    model: "gemini-2.5-flash-lite",
    models: ["gemini-2.5-flash-lite", "gemini-2.5-flash", "gemini-2.0-flash", "gemma-3-27b-it"],
    keyUrl: "https://aistudio.google.com/apikey",
    freeTier: "No card. Best Indic-language quality. Daily quota varies by model (Flash-Lite is the generous one); check AI Studio.",
  },
  openrouter: {
    label: "OpenRouter",
    baseUrl: "https://openrouter.ai/api/v1",
    model: "meta-llama/llama-3.3-70b-instruct:free",
    models: ["meta-llama/llama-3.3-70b-instruct:free", "google/gemma-3-27b-it:free", "deepseek/deepseek-chat-v3-0324:free", "qwen/qwen3-235b-a22b:free"],
    keyUrl: "https://openrouter.ai/keys",
    freeTier: "No card. 20 req/min, 50 req/day (1,000/day after a one-time $10 top-up). Good as last resort.",
  },
  cerebras: {
    label: "Cerebras",
    baseUrl: "https://api.cerebras.ai/v1",
    model: "llama-3.3-70b",
    models: ["llama-3.3-70b", "llama3.1-8b", "qwen-3-32b"],
    keyUrl: "https://cloud.cerebras.ai",
    freeTier: "No card. ~30 req/min, ~1M tokens/day. Very fast.",
  },
  mistral: {
    label: "Mistral",
    baseUrl: "https://api.mistral.ai/v1",
    model: "mistral-small-latest",
    models: ["mistral-small-latest", "open-mistral-nemo"],
    keyUrl: "https://console.mistral.ai/api-keys",
    freeTier: "Free experiment tier, roughly 1B tokens/month. Data may be used for training.",
  },
  custom: {
    label: "Custom / Ollama",
    baseUrl: "http://host.docker.internal:11434/v1",
    model: "llama3.2",
    models: [],
    keyUrl: "",
    freeTier: "Any OpenAI-compatible endpoint (Ollama, LM Studio, vLLM). Fully free if you host it.",
  },
};

// preset -> unix ms until which we skip it (set after 429 / 5xx)
const cooldowns = new Map();
const COOLDOWN_MS = 60 * 1000;

function resolveProvider(p) {
  const preset = PRESETS[p.preset] || PRESETS.custom;
  return {
    preset: p.preset || "custom",
    label: p.label || preset.label,
    baseUrl: (p.baseUrl || preset.baseUrl).replace(/\/+$/, ""),
    apiKey: p.apiKey || "",
    model: p.model || preset.model,
    enabled: p.enabled !== false,
  };
}

class ProviderError extends Error {
  constructor(message, { status, retryable }) {
    super(message);
    this.status = status;
    this.retryable = retryable;
  }
}

async function callProvider(provider, messages, { temperature, maxTokens, timeoutMs }) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  const started = Date.now();
  try {
    const headers = { "Content-Type": "application/json" };
    if (provider.apiKey) headers.Authorization = `Bearer ${provider.apiKey}`;
    if (provider.preset === "openrouter") {
      headers["HTTP-Referer"] = "https://bebuapp.in";
      headers["X-Title"] = "bebu";
    }
    const res = await fetch(`${provider.baseUrl}/chat/completions`, {
      method: "POST",
      headers,
      signal: controller.signal,
      body: JSON.stringify({ model: provider.model, messages, temperature, max_tokens: maxTokens, stream: false }),
    });
    const latencyMs = Date.now() - started;
    if (!res.ok) {
      const text = (await res.text().catch(() => "")).slice(0, 300);
      const retryable = res.status === 429 || res.status >= 500 || res.status === 408;
      throw new ProviderError(`${provider.label} ${res.status}: ${text || res.statusText}`, { status: res.status, retryable });
    }
    const json = await res.json();
    const content = json?.choices?.[0]?.message?.content;
    if (typeof content !== "string" || !content.trim()) {
      throw new ProviderError(`${provider.label}: empty completion`, { status: 502, retryable: true });
    }
    return {
      text: content.trim(),
      latencyMs,
      inputTokens: json?.usage?.prompt_tokens || 0,
      outputTokens: json?.usage?.completion_tokens || 0,
      model: json?.model || provider.model,
    };
  } catch (err) {
    if (err.name === "AbortError") throw new ProviderError(`${provider.label}: timed out after ${timeoutMs}ms`, { status: 408, retryable: true });
    if (err instanceof ProviderError) throw err;
    throw new ProviderError(`${provider.label}: ${err.message}`, { status: 0, retryable: true });
  } finally {
    clearTimeout(timer);
  }
}

/**
 * Try providers in order; skip ones cooling down after a rate limit.
 * Returns { ...completion, provider } or throws the last error.
 */
async function completeWithFailover(rawProviders, messages, opts) {
  const providers = (rawProviders || []).map(resolveProvider).filter((p) => p.enabled && (p.apiKey || p.preset === "custom"));
  if (!providers.length) throw new ProviderError("No AI provider configured", { status: 0, retryable: false });

  const now = Date.now();
  const ordered = [...providers.filter((p) => (cooldowns.get(p.preset + p.model) || 0) <= now), ...providers.filter((p) => (cooldowns.get(p.preset + p.model) || 0) > now)];

  let lastErr;
  for (const provider of ordered) {
    try {
      const out = await callProvider(provider, messages, opts);
      cooldowns.delete(provider.preset + provider.model);
      return { ...out, provider: provider.preset, providerLabel: provider.label };
    } catch (err) {
      lastErr = err;
      console.log(`⚠️ AI provider failed: ${err.message}`);
      if (err.status === 429 || err.status >= 500) cooldowns.set(provider.preset + provider.model, Date.now() + COOLDOWN_MS);
      if (!err.retryable && err.status !== 401 && err.status !== 403) break;
    }
  }
  throw lastErr;
}

function cooldownState() {
  const now = Date.now();
  return Object.fromEntries([...cooldowns.entries()].filter(([, until]) => until > now).map(([k, until]) => [k, Math.ceil((until - now) / 1000)]));
}

module.exports = { PRESETS, resolveProvider, callProvider, completeWithFailover, cooldownState, ProviderError };
