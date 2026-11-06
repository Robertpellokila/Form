import { createRouter, createWebHistory } from 'vue-router'
import TestView from './views/TestView.vue'

// Tidak ada link ke /admin dari halaman publik: admin membuka alamat ini secara manual.
export default createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: TestView },
    { path: '/admin', component: () => import('./views/AdminView.vue') },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
  scrollBehavior: () => ({ top: 0 }),
})
