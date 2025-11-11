import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { mockPlans } from '@/utils/mockData'
import { eSIMPlan } from '@/types'

const ShopPlans = () => {
  const navigate = useNavigate()
  const [selectedRegion, setSelectedRegion] = useState<string>('All')

  const regions = ['All', ...Array.from(new Set(mockPlans.flatMap(plan => plan.regions)))]

  const filteredPlans = selectedRegion === 'All'
    ? mockPlans
    : mockPlans.filter(plan => plan.regions.includes(selectedRegion))

  const handleBuyNow = (plan: eSIMPlan) => {
    // Navigate to checkout with plan data
    navigate('/checkout', { state: { plan } })
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="text-center mb-12"
      >
        <h1 className="text-4xl md:text-5xl font-bold mb-6 text-gray-900 dark:text-white">
          Shop eSIM Plans
        </h1>
        <p className="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
          Choose the perfect plan for your travel needs. All plans include instant activation and global support.
        </p>
      </motion.div>

      {/* Region Filter */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.1 }}
        className="mb-8"
      >
        <div className="flex flex-wrap gap-2 justify-center">
          {regions.map((region) => (
            <button
              key={region}
              onClick={() => setSelectedRegion(region)}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                selectedRegion === region
                  ? 'bg-telgo-red text-white'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              {region}
            </button>
          ))}
        </div>
      </motion.div>

      {/* Plans Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {filteredPlans.map((plan, index) => (
          <motion.div
            key={plan.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: index * 0.1 }}
            className={`bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden ${
              plan.popular ? 'ring-2 ring-telgo-red' : ''
            }`}
          >
            {plan.popular && (
              <div className="bg-telgo-red text-white text-center py-2 text-sm font-semibold">
                Most Popular
              </div>
            )}
            <div className="p-6">
              <h3 className="text-2xl font-bold mb-2 text-gray-900 dark:text-white">
                {plan.name}
              </h3>
              <p className="text-gray-600 dark:text-gray-400 mb-4">
                {plan.description}
              </p>
              <div className="mb-6">
                <span className="text-4xl font-bold text-gray-900 dark:text-white">
                  {plan.currency} {plan.price}
                </span>
              </div>
              <div className="mb-6 space-y-3">
                <div className="flex items-center text-gray-700 dark:text-gray-300">
                  <svg className="w-5 h-5 text-telgo-red mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                  <span className="font-semibold">{plan.data} Data</span>
                </div>
                <div className="flex items-center text-gray-700 dark:text-gray-300">
                  <svg className="w-5 h-5 text-telgo-red mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                  <span>{plan.validity} Validity</span>
                </div>
                <div className="flex items-center text-gray-700 dark:text-gray-300">
                  <svg className="w-5 h-5 text-telgo-red mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                  <span>{plan.regions.join(', ')} Coverage</span>
                </div>
              </div>
              <div className="mb-6">
                <h4 className="font-semibold mb-2 text-gray-900 dark:text-white">Features:</h4>
                <ul className="space-y-2">
                  {plan.features.map((feature, idx) => (
                    <li key={idx} className="flex items-start text-sm text-gray-600 dark:text-gray-400">
                      <svg className="w-4 h-4 text-telgo-red mr-2 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      <span>{feature}</span>
                    </li>
                  ))}
                </ul>
              </div>
              <button
                onClick={() => handleBuyNow(plan)}
                className="w-full py-3 bg-telgo-red text-white rounded-lg font-semibold hover:bg-red-700 transition-colors"
              >
                Buy Now
              </button>
            </div>
          </motion.div>
        ))}
      </div>

      {/* No plans message */}
      {filteredPlans.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center py-12 text-gray-500 dark:text-gray-400"
        >
          No plans available for the selected region.
        </motion.div>
      )}

      {/* Info Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.4 }}
        className="mt-12 bg-gray-50 dark:bg-gray-800 rounded-lg p-8"
      >
        <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
          Why Choose TTelGo Plans?
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[
            { icon: '⚡', text: 'Instant Activation' },
            { icon: '🌍', text: 'Global Coverage' },
            { icon: '💰', text: 'No Hidden Fees' },
          ].map((item, index) => (
            <div key={index} className="flex items-center space-x-3">
              <div className="text-3xl">{item.icon}</div>
              <span className="text-gray-700 dark:text-gray-300">{item.text}</span>
            </div>
          ))}
        </div>
        <div className="mt-6 text-center">
          <Link
            to="/help"
            className="text-telgo-red hover:text-red-700 font-medium"
          >
            Need help choosing a plan? Visit our Help Centre →
          </Link>
        </div>
      </motion.div>
    </div>
  )
}

export default ShopPlans

