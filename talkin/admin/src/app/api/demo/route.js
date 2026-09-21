import { getAuthHeaders } from '@/libs/getAuthHeaders'

export async function GET(request) {
  const headers = await getAuthHeaders()
  
  console.log('headers-->', headers)

  return new Response(JSON.stringify({ message: 'Hello from API!' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
