const PaymentOption = require("../../models/paymentOption.model");

//get all Payment Options
exports.getAvailablePaymentOptions = async (req, res) => {
  try {
    const options = await PaymentOption.find().sort({ createdAt: -1 }).lean();

    return res.status(200).json({
      status: true,
      message: "Retrieved all payment options.",
      data: options,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ status: false, message: error.message || "Internal Server Error" });
  }
};
