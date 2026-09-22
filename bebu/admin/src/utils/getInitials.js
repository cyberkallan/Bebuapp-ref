export const getInitials = (string) => {
  if (!string) return "-";

  const words = string.trim().split(/\s+/);

  return words.length === 1
    ? words[0].charAt(0).toUpperCase()
    : words.map(word => word[0].toUpperCase()).join("");
};
