// User types
export interface User {
  id: string
  email: string
  name: string
}

// eSIM types
export interface eSIMPlan {
  id: string
  name: string
  description: string
  price: number
  currency: string
  data: string
  validity: string
  regions: string[]
  features: string[]
  popular?: boolean
}

export interface eSIMStatus {
  id: string
  planName: string
  status: 'active' | 'inactive' | 'expired' | 'pending'
  dataRemaining: string
  validity: string
  qrCode: string
  activationDate?: string
  expirationDate?: string
}

// FAQ types
export interface FAQ {
  id: string
  question: string
  answer: string
  category: string
}

// Form types
export interface LoginForm {
  email: string
  password: string
}

export interface SignUpForm {
  email: string
  password: string
  confirmPassword: string
  referralCode?: string
}

