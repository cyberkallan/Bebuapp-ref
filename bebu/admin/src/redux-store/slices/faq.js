import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

// Helpers
const getAuthHeaders = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    return {
      'Content-Type': 'application/json',
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    }
  }

  return {}
}

// Fetch FAQs with pagination and filtering
export const fetchFaqs = createAsyncThunk(
  'faq/getFaqs',
  async ({ category = 'User', start = 1, limit = 10 }, thunkAPI) => {
    try {
      // Access the current state
      const state = thunkAPI.getState().faqs

      // Use the state's start value if not provided
      let startPage = start

      // If start wasn't passed or it's not a valid number, use state.start
      if (startPage === undefined || startPage === null) {
        startPage = state.start
      }

      const response = await axios.get(`${baseURL}/api/admin/faq/getFaqs`, {
        headers: getAuthHeaders(),
        params: {
          category,
          start: startPage,
          limit
        }
      })

      return { ...response.data, category, startPage }
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Create FAQ
export const createFaq = createAsyncThunk('faq/createFaq', async (data, thunkAPI) => {
  try {
    const response = await axios.post(
      `${baseURL}/api/admin/faq/createFaq`,
      {},
      {
        headers: getAuthHeaders(),
        params: {
          category: thunkAPI.getState().faqs.selectedCategory,
          question: data.question,
          answer: data.answer
        }
      }
    )

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

// Update FAQ
export const updateFaq = createAsyncThunk('faq/updateFaq', async (data, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${baseURL}/api/admin/faq/updateFaq`,
      {},
      {
        headers: getAuthHeaders(),
        params: {
          faqId: data.faqId,
          category: data.category,
          question: data.question,
          answer: data.answer
        }
      }
    )

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

// Delete FAQ
export const deleteFaq = createAsyncThunk('faq/deleteFaq', async (faqId, thunkAPI) => {
  try {
    const response = await axios.delete(`${baseURL}/api/admin/faq/deleteFaq`, {
      headers: getAuthHeaders(),
      params: {
        faqId
      }
    })

    return { ...response.data, faqId }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

const initialState = {
  loading: false,
  initialLoading: true,
  faqs: [],
  selectedCategory: 'User',
  error: null,
  start: 1,
  limit: 10,
  total: 0,
  hasMore: true
}

const faqsSlice = createSlice({
  name: 'faqs',
  initialState,
  reducers: {
    setCategory: (state, action) => {
      // Only reset if changing category
      if (state.selectedCategory !== action.payload) {
        state.selectedCategory = action.payload
        state.start = 1
        state.faqs = []
        state.hasMore = true
        state.initialLoading = true
      }
    },
    resetPagination: state => {
      state.start = 1
    },
    setPage: (state, action) => {
      state.start = action.payload
    },
    setLimit: (state, action) => {
      state.limit = action.payload
    }
  },
  extraReducers: builder => {
    // Fetch FAQs
    builder.addCase(fetchFaqs.pending, (state, action) => {
      // Only set initialLoading to true if it's the first fetch
      if (state.start === 1) {
        state.initialLoading = true
      }
      
      state.loading = true
    })
    builder.addCase(fetchFaqs.fulfilled, (state, action) => {
      state.loading = false
      state.initialLoading = false

      if (action.payload.status) {
        // Verify the returned faqs are for the currently selected category
        if (action.payload.category === state.selectedCategory) {
          const newFaqs = action.payload.data

          // Filter out any duplicate faqs by ID that might already exist in state
          const existingIds = new Set(state.faqs.map(faq => faq._id))
          const uniqueNewFaqs = newFaqs.filter(faq => !existingIds.has(faq._id))

          // If this is the first page (start=1), replace the faqs array
          // Otherwise append for pagination
          if (state.start === 1) {
            state.faqs = newFaqs
          } else {
            state.faqs = [...state.faqs, ...uniqueNewFaqs]
          }

          state.total = action.payload.total

          // Fix hasMore calculation to be more precise
          state.hasMore = state.faqs.length < action.payload.total

          // Only increment start if we received the expected number of faqs
          if (uniqueNewFaqs.length > 0 && uniqueNewFaqs.length >= state.limit) {
            state.start = state.start + 1
          } else if (state.faqs.length >= action.payload.total) {
            // We've reached the end
            state.hasMore = false
          }
        }
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchFaqs.rejected, (state, action) => {
      state.loading = false
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Create FAQ
    builder.addCase(createFaq.pending, state => {
      state.loading = true
    })
    builder.addCase(createFaq.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        // Only add new faq if we're currently viewing the same category
        if (state.selectedCategory === action.payload.data.category) {
          // Add new faq to the beginning of the list
          state.faqs = [action.payload.data, ...state.faqs]
          state.total += 1
        }

        toast.success(action.payload.message || 'FAQ created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createFaq.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update FAQ
    builder.addCase(updateFaq.pending, state => {
      state.loading = true
    })
    builder.addCase(updateFaq.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        // Update the faq in the list
        const index = state.faqs.findIndex(faq => faq._id === action.payload.data._id)

        if (index !== -1) {
          // Update the faq
          state.faqs[index] = action.payload.data

          // Create a new array to ensure React detects the change
          state.faqs = [...state.faqs]
        }

        toast.success(action.payload.message || 'FAQ updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateFaq.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete FAQ
    builder.addCase(deleteFaq.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteFaq.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.faqs = state.faqs.filter(faq => faq._id !== action.payload.faqId)
        state.total -= 1
        toast.success(action.payload.message || 'FAQ deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteFaq.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setCategory, resetPagination, setPage, setLimit } = faqsSlice.actions

export default faqsSlice.reducer
