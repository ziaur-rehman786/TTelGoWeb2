import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Layout from './components/Layout/Layout'
import Home from './pages/Home'
import About from './pages/About'
import DownloadApp from './pages/DownloadApp'
import HelpCentre from './pages/HelpCentre'
import MyeSIM from './pages/MyeSIM'
import Login from './pages/Login'
import SignUp from './pages/SignUp'
import ShopPlans from './pages/ShopPlans'
import Checkout from './pages/Checkout'
import RegionCountries from './pages/RegionCountries'
import CountryPackages from './pages/CountryPackages'
import GlobalESIMPlans from './pages/GlobalESIMPlans'
import Contact from './pages/Contact'
import Blog from './pages/Blog'
import UltimateGuideESIMTravel from './pages/blog/UltimateGuideESIMTravel'
import SaveMoneyESIMvsRoaming from './pages/blog/SaveMoneyESIMvsRoaming'
import ESIMSetupGuideBeginners from './pages/blog/ESIMSetupGuideBeginners'

function App() {
  return (
    <Router>
      <Routes>
        {/* All routes with Layout (header on all pages, footer hidden on login/signup) */}
        <Route element={<Layout />}>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/download" element={<DownloadApp />} />
          <Route path="/help" element={<HelpCentre />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="/blog" element={<Blog />} />
          <Route path="/blog/ultimate-guide-esim-travel-2024" element={<UltimateGuideESIMTravel />} />
          <Route path="/blog/save-money-esim-vs-roaming" element={<SaveMoneyESIMvsRoaming />} />
          <Route path="/blog/esim-setup-guide-beginners" element={<ESIMSetupGuideBeginners />} />
          <Route path="/my-esim" element={<MyeSIM />} />
          <Route path="/shop" element={<ShopPlans />} />
          <Route path="/region/:regionName" element={<RegionCountries />} />
          <Route path="/country/:countryName" element={<CountryPackages />} />
          <Route path="/global-esim" element={<GlobalESIMPlans />} />
          <Route path="/checkout" element={<Checkout />} />
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<SignUp />} />
        </Route>
      </Routes>
    </Router>
  )
}

export default App

