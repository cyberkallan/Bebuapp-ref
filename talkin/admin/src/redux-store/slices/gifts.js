import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const BASE_URL = baseURL

// Helper to get auth headers
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

export const fetchGiftsCategories = createAsyncThunk('gifts/fetchCategories', async (_, thunkAPI) => {
  try {
    const state = thunkAPI.getState().giftReducer
    const { page, pageSize } = state

    // Add pagination parameters to the API request
    const response = await axios.get(
      `${BASE_URL}/api/admin/giftCategory/fetchGiftCategories?page=${page}&limit=${pageSize}`,
      {
        headers: getAuthHeaders()
      }
    )

    // Return both the categories and pagination data
    return {
      categories: response.data.data || [],
      total: response.data.total || response.data.data.length,
      page: page,
      pageSize: pageSize
    }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

export const createGiftCategory = createAsyncThunk('gifts/createCategory', async (name, thunkAPI) => {
  try {
    const response = await axios.post(
      `${BASE_URL}/api/admin/giftCategory/addGiftCategory?name=${name}`,
      {},
      { headers: getAuthHeaders() }
    )

    toast.success(response.data.message || 'Category created')

    return response.data.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

export const updateGiftCategory = createAsyncThunk('gifts/updateCategory', async ({ name, categoryId }, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/giftCategory/modifyGiftCategory?name=${name}&categoryId=${categoryId}`,
      {},
      { headers: getAuthHeaders() }
    )

    toast.success(response.data.message || 'Category updated')

    return response.data.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

export const deleteGiftCategory = createAsyncThunk('gifts/deleteCategory', async (categoryId, thunkAPI) => {
  try {
    const response = await axios.delete(
      `${BASE_URL}/api/admin/giftCategory/removeGiftCategory?categoryId=${categoryId}`,
      { headers: getAuthHeaders() }
    )

    toast.success(response.data.message || 'Category deleted')

    return { id: categoryId }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

export const getAllGifts = createAsyncThunk('gifts/getAll', async (_, thunkAPI) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/gift/getGifts`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

// 🟢 CREATE GIFT
export const createGift = createAsyncThunk('gifts/createGift', async (formData, { rejectWithValue }) => {
  try {
    const res = await axios.post(`${BASE_URL}/api/admin/gift/createGift`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return res.data // Expected shape: newly created gift with giftCategoryId
  } catch (err) {
    return rejectWithValue(err.response?.data?.message || 'Failed to create gift')
  }
})

// 🟡 UPDATE GIFT
export const updateGift = createAsyncThunk('gifts/updateGift', async (formData, { rejectWithValue }) => {
  try {
    const res = await axios.patch(`${BASE_URL}/api/admin/gift/updateGift`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return res.data // Expected shape: updated gift with giftCategoryId
  } catch (err) {
    return rejectWithValue(err.response?.data?.message || 'Failed to update gift')
  }
})

export const deleteGift = createAsyncThunk('gifts/deleteGift', async ({ giftId }, { rejectWithValue }) => {
  try {
    const res = await axios.delete(`${BASE_URL}/api/admin/gift/deleteGift?giftId=${giftId}`, {
      headers: getAuthHeaders()
    })

    return res.data
  } catch (err) {
    return rejectWithValue(err.response?.data?.message || 'Failed to delete gift')
  }
})

const initialState = {
  gifts: [],
  categories: [],
  loading: false,
  initialLoading: true,
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const giftsSlice = createSlice({
  name: 'gifts',
  initialState,
  reducers: {
    setCategoryPage: (state, action) => {
      state.page = action.payload
    },
    setCategoryPageSize: (state, action) => {
      state.pageSize = action.payload
      state.page = 1
    }
  },
  extraReducers: builder => {
    builder

      //_______________________________________________GIFT-CATEGORY_____________________________________________________

      // Fetch
      .addCase(fetchGiftsCategories.pending, state => {
        state.initialLoading = true
        state.error = null
      })
      .addCase(fetchGiftsCategories.fulfilled, (state, action) => {
        state.initialLoading = false

        // Check if we received the new pagination format
        if (action.payload.categories) {
          state.categories = action.payload.categories
          state.total = action.payload.total
          state.page = action.payload.page
          state.pageSize = action.payload.pageSize
        } else {
          // Fallback for backward compatibility
          state.categories = action.payload
          state.total = action.payload.length
        }
      })
      .addCase(fetchGiftsCategories.rejected, (state, action) => {
        state.initialLoading = false
        state.error = action.payload
      })

      // Create
      .addCase(createGiftCategory.fulfilled, (state, action) => {
        state.categories.push(action.payload)
      })

      // Update
      .addCase(updateGiftCategory.fulfilled, (state, action) => {
        const updated = action.payload

        // Update in categories list
        state.categories = state.categories.map(category =>
          category._id === updated._id ? { ...category, name: updated.name } : category
        )

        // Update in main gifts list (used in GiftCategoriesPage)
        state.gifts = state.gifts.map(category =>
          category._id === updated._id ? { ...category, categoryName: updated.name } : category
        )
      })

      // Delete
      .addCase(deleteGiftCategory.fulfilled, (state, action) => {
        state.categories = state.categories.filter(category => category._id !== action.payload.id)
        state.gifts = state.gifts.filter(category => category._id !== action.payload.id)
      })
      .addCase(deleteGiftCategory.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })

      //_______________________________________________GIFTS_______________________________________________________
      // Fetch
      .addCase(getAllGifts.pending, state => {
        state.loading = true
        state.initialLoading = true
        state.error = null
      })
      .addCase(getAllGifts.fulfilled, (state, action) => {
        state.loading = false
        state.initialLoading = false

        if (action.payload.status) {
          state.gifts = action.payload.data
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(getAllGifts.rejected, (state, action) => {
        state.loading = false
        state.initialLoading = false
        state.error = action.payload
        toast.error(action.payload)
      })

      // Create
      .addCase(createGift.pending, state => {
        state.loading = true
      })
      .addCase(createGift.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          const newGift = action.payload.data
          const categoryId = newGift.giftCategoryId
          const category = state.gifts.find(cat => cat._id === categoryId)

          if (category) {
            category.gifts.push(newGift)
          } else {
            const categoryData = state.categories.find(cat => cat._id === categoryId)

            if (categoryData) {
              state.gifts.push({
                _id: categoryId,
                categoryName: categoryData.name || categoryData.categoryName,
                gifts: [newGift]
              })
            }
          }
        } else {
          toast.error(action.payload.message)
        }

        state.loading = false
      })
      .addCase(createGift.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })

      // Update
      .addCase(updateGift.pending, state => {
        state.loading = true
      })
      .addCase(updateGift.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          const updatedGift = action.payload.data
          const categoryId = updatedGift.giftCategoryId
          const category = state.gifts.find(cat => cat._id === categoryId)

          if (category) {
            const idx = category.gifts.findIndex(g => g._id === updatedGift._id)

            if (idx !== -1) category.gifts[idx] = updatedGift
          }

          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(updateGift.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload.message
        toast.error(action.payload.message)
      })

      // Delete
      .addCase(deleteGift.pending, state => {
        state.loading = true
      })
      .addCase(deleteGift.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          const { giftId } = action.payload

          for (const category of state.gifts) {
            category.gifts = category.gifts.filter(gift => gift._id !== action.meta.arg.giftId)
          }
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(deleteGift.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload.message
        toast.error(action.payload.message)
      })
  }
})

export const { setCategoryPage, setCategoryPageSize } = giftsSlice.actions

export default giftsSlice.reducer
