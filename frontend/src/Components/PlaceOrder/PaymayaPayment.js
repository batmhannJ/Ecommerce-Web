import axios from "axios";
import config from "./config.js";
import { v4 as uuidv4 } from "uuid";
import { Buffer } from "buffer";

const mayaCheckoutUrl = config.maya_checkout.url;
const hostUrl = config.host_url;
const token = Buffer.from(
  `${config.maya_checkout.pub_api_key}:`,
  "binary"
).toString("base64");
const requestReferenceNumber = uuidv4();

export const CreateCheckout = async () => {
  const options = {
    method: "POST",
    url: `${mayaCheckoutUrl}`,
    headers: {
      accept: "application/json",
      "content-type": "application/json",
      authorization: `Basic ${token}`,
    },
    data: {
      totalAmount: {
        currency: "PHP",
        value: "1000",
        details: {
          discount: "100.00",
          serviceCharge: "0.00",
          shippingFee: "200.00",
          tax: "120.00",
          subtotal: "780.00",
        },
      },
      buyer: {
        contact: { phone: "+639180000123", email: "maya.juan@mail.com" },
        billingAddress: {
          line1: "6F Launchpad",
          line2: "Reliance Street",
          city: "Mandaluyong City",
          state: "Metro Manila",
          zipCode: "1552",
          countryCode: "PH",
        },
        shippingAddress: {
          firstName: "Maya",
          lastName: "Juan",
          phone: "+639180000123",
          email: "maya.juan@mail.com",
          shippingType: "SD",
          line1: "6F Launchpad",
          line2: "Reliance Street",
          city: "Mandaluyong City",
          state: "Metro Manila",
          zipCode: "1552",
          countryCode: "PH",
        },
        firstName: "Francis",
        lastName: "Gonzales",
      },
      redirectUrl: {
        success: `${hostUrl}/success?id=${requestReferenceNumber}`,
        failure: `${hostUrl}/failure?id=${requestReferenceNumber}`,
        cancel: `${hostUrl}/cancel?id=${requestReferenceNumber}`,
      },
      items: [
        {
          name: "Canvas Slip Ons",
          code: "CVG-096732",
          description: "Shoes",
          quantity: "1",
          amount: { value: "1000.00" },
          totalAmount: { value: "1000.00" },
        },
      ],
      requestReferenceNumber: "5fc10b93-bdbd-4f31-b31d-4575a3785009",
    },
  };

  axios
    .request(options)
    .then(function (response) {
      console.log(response.data);
      return response.redirectUrl;
    })
    .catch(function (error) {
      console.error(error);
    });
};
// import axios from "axios";
// import config from "./config.js";
// import { v4 as uuidv4 } from "uuid";
// import { Buffer } from "buffer";
// import { toast } from "react-toastify";

// const mayaCheckoutUrl = config.maya_checkout.url;
// const hostUrl = config.host_url;
// const token = Buffer.from(
//   `${config.maya_checkout.pub_api_key}:`,
//   "binary"
// ).toString("base64");
// const requestReferenceNumber = uuidv4();

// export const CreateCheckout = async () => {
//   const options = {
//     data: {
//       totalAmount: {
//         currency: "PHP",
//         value: "1000",
//         details: {
//           discount: "100.00",
//           serviceCharge: "0.00",
//           shippingFee: "200.00",
//           tax: "120.00",
//           subtotal: "780.00",
//         },
//       },
//       buyer: {
//         contact: { phone: "+639180000123", email: "maya.juan@mail.com" },
//         billingAddress: {
//           line1: "6F Launchpad",
//           line2: "Reliance Street",
//           city: "Mandaluyong City",
//           state: "Metro Manila",
//           zipCode: "1552",
//           countryCode: "PH",
//         },
//         shippingAddress: {
//           firstName: "Maya",
//           lastName: "Juan",
//           phone: "+639180000123",
//           email: "maya.juan@mail.com",
//           shippingType: "SD",
//           line1: "6F Launchpad",
//           line2: "Reliance Street",
//           city: "Mandaluyong City",
//           state: "Metro Manila",
//           zipCode: "1552",
//           countryCode: "PH",
//         },
//         firstName: "Francis",
//         lastName: "Gonzales",
//       },
//       redirectUrl: {
// success: `${hostUrl}/success?id=${requestReferenceNumber}`,
// failure: `${hostUrl}/failure?id=${requestReferenceNumber}`,
// cancel: `${hostUrl}/cancel?id=${requestReferenceNumber}`,
//       },
//       items: [
//         {
//           name: "Canvas Slip Ons",
//           code: "CVG-096732",
//           description: "Shoes",
//           quantity: "1",
//           amount: { value: "1000.00" },
//           totalAmount: { value: "1000.00" },
//         },
//       ],
//       requestReferenceNumber,
//     },
//   };
//   const headers = {
//     accept: "application/json",
//     authorization: `Basic ${token}`,
//     "content-type": "application/json",
//   };

//   const response = await axios.post(`${mayaCheckoutUrl}`, options, { headers });
//   window.location.href = checkout?.redirectUrl
//   return response;
// };
