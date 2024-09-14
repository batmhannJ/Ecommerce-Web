import "./App.css";
import Navbar from "./Components/Navbar/Navbar";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Shop from "./Pages/Shop";
import Product from "./Pages/Product";
import ShopCategory from "./Pages/ShopCategory";
import Cart from "./Pages/Cart";
import LoginSignup from "./Pages/LoginSignup";
import Footer from "./Components/Footer/Footer";
import PlaceOrder from "./Components/PlaceOrder/PlaceOrder";
import Crafts_Banner from "./Components/Assets/Clothes_Banner.png";
import Clothes_Banner from "./Components/Assets/Crafts_Banner.png";
import Food_Banner from "./Components/Assets/Food_Banner.png";
import Verify from "./Components/Verify/Verify";
import MyOrders from "./Components/MyOrders/MyOrders";
import About from "./Components/About/About";
import UserProfile from "./Pages/User/UserProfile";
import UserSideBar from "./Components/UserProfile/UserSideBar";
import AccountSettings from "./Components/UserProfile/AccountSettings";

function App() {
  return (
    <BrowserRouter>
      <Navbar />
      <Routes>
        <Route path="/" element={<Shop />} />
        <Route path="/about" element={<About />} />
        <Route
          path="/crafts"
          element={<ShopCategory banner={Crafts_Banner} category="crafts" />}
        />
        <Route
          path="/clothes"
          element={<ShopCategory banner={Clothes_Banner} category="clothes" />}
        />
        <Route
          path="/food"
          element={<ShopCategory banner={Food_Banner} category="food" />}
        />
        <Route path="/product" element={<Product />}>
          <Route path=":productId" element={<Product />} />
        </Route>
        <Route path="/cart" element={<Cart />} />
        <Route path="/login" element={<LoginSignup />} />
        <Route path="/order" element={<PlaceOrder />} />
        <Route path="/verify" element={<Verify />} />
        <Route path="/myorders/:rrn" element={<MyOrders />} />
        <Route path="/user/:activepage" element={<UserProfile />} />
        <Route path="usersidebar" element={<UserSideBar />} />
        <Route path="accountsettings" element={<AccountSettings />} />
        <Route path="about" element={<About />} />
      </Routes>
      <Footer />
    </BrowserRouter>
  );
}

export default App;
