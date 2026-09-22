import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

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

export const fetchIdentityProofs = createAsyncThunk('identityProofs/fetchIdentityProofs', async (params, thunkAPI) => {
  try {
    const { page, pageSize } = params
    
    const response = await axios.get(`${baseURL}/api/admin/identityProof/fetchIdentityProofs`, {
      headers: getAuthHeaders(),
      params: {
        page: page || 1,
        limit: pageSize || 10
      }
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const createIdentityProof = createAsyncThunk('identityProofs/createIdentityProof', async (payload, thunkAPI) => {
  try {
    const response = await axios.post(
      `${baseURL}/api/admin/identityProof/addIdentityProof?title=${encodeURIComponent(payload.title)}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const updateIdentityProof = createAsyncThunk('identityProofs/updateIdentityProof', async (payload, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${baseURL}/api/admin/identityProof/modifyIdentityProof?title=${encodeURIComponent(payload.title)}&identityProofId=${payload.identityProofId}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const deleteIdentityProof = createAsyncThunk(
  'identityProofs/deleteIdentityProof',
  async (identityProofId, thunkAPI) => {
    try {
      const response = await axios.delete(
        `${baseURL}/api/admin/identityProof/removeIdentityProof?identityProofId=${identityProofId}`,
        {
          headers: getAuthHeaders()
        }
      )

      return { ...response.data, identityProofId }
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

const initialState = {
  initialLoading: true,
  loading: false,
  identityProofs: [],
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const identityProofsSlice = createSlice({
  name: 'identityProofs',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
      state.page = 1 // Reset to first page when changing page size
    }
  },
  extraReducers: builder => {
    // Fetch identity proofs
    builder.addCase(fetchIdentityProofs.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchIdentityProofs.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.identityProofs = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchIdentityProofs.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Create identity proof
    builder.addCase(createIdentityProof.pending, state => {
      state.loading = true
    })
    builder.addCase(createIdentityProof.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.identityProofs = [...state.identityProofs, action.payload.data]
        state.total += 1
        toast.success(action.payload.message || 'Identity proof added successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createIdentityProof.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update identity proof
    builder.addCase(updateIdentityProof.pending, state => {
      state.loading = true
    })
    builder.addCase(updateIdentityProof.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.identityProofs.findIndex(identityProof => identityProof._id === action.payload.data._id)

        if (index !== -1) {
          state.identityProofs[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Identity proof updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateIdentityProof.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete identity proof
    builder.addCase(deleteIdentityProof.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteIdentityProof.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.identityProofs = state.identityProofs.filter(
          identityProof => identityProof._id !== action.payload.identityProofId
        )
        state.total -= 1
        toast.success(action.payload.message || 'Identity proof deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteIdentityProof.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = identityProofsSlice.actions

export default identityProofsSlice.reducer
