// Import the functions you need from the SDKs you need


import { initializeApp } from 'firebase/app'
import { getAuth } from 'firebase/auth'

import {
  firebase_apiKey,
  firebase_appId,
  firebase_authDomain,
  firebase_measurementId,
  firebase_messagingSenderId,
  firebase_projectId,
  firebase_storageBucket
} from '@/config'

// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: firebase_apiKey,
  authDomain: firebase_authDomain,
  projectId: firebase_projectId,
  storageBucket: firebase_storageBucket,
  messagingSenderId: firebase_messagingSenderId,
  appId: firebase_appId,
  measurementId: firebase_measurementId
}

// Initialize Firebase
const app = initializeApp(firebaseConfig)

export const auth = getAuth(app)
