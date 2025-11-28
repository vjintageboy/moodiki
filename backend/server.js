const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const axios = require('axios');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// MoMo Config
const config = {
    partnerCode: "MOMO",
    accessKey: "F8BBA842ECF85",
    secretKey: "K951B6PE1waDMi640xX08PD3vg6EkVlz",
    endpoint: "https://test-payment.momo.vn/v2/gateway/api/create"
};

app.post('/momo/create', async (req, res) => {
    try {
        const { amount } = req.body;

        if (!amount) {
            return res.status(400).json({ message: "Amount is required" });
        }

        const orderId = "MOMO" + new Date().getTime();
        const requestId = orderId;
        const orderInfo = "Thanh toan don hang " + orderId;
        const redirectUrl = "https://google.com";
        const ipnUrl = "https://google.com";
        const requestType = "captureWallet";
        const extraData = "";
        const amountStr = amount.toString();

        // Signature Generation
        const rawSignature =
            `accessKey=${config.accessKey}&amount=${amountStr}&extraData=${extraData}&ipnUrl=${ipnUrl}` +
            `&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${config.partnerCode}` +
            `&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=${requestType}`;

        const signature = crypto
            .createHmac('sha256', config.secretKey)
            .update(rawSignature)
            .digest('hex');

        const requestBody = {
            partnerCode: config.partnerCode,
            partnerName: "Test",
            storeId: "MoMoTestStore",
            requestId: requestId,
            amount: amountStr,
            orderId: orderId,
            orderInfo: orderInfo,
            redirectUrl: redirectUrl,
            ipnUrl: ipnUrl,
            lang: "vi",
            extraData: extraData,
            requestType: requestType,
            signature: signature
        };

        console.log("Sending to MoMo:", requestBody);

        const response = await axios.post(config.endpoint, requestBody);

        console.log("MoMo Response:", response.data);

        return res.status(200).json(response.data);

    } catch (error) {
        console.error("Error:", error.message);
        if (error.response) {
            console.error("MoMo Error Body:", error.response.data);
        }
        return res.status(500).json({
            message: "Internal Server Error",
            details: error.message
        });
    }
});

app.post('/momo/query', async (req, res) => {
    try {
        const { orderId } = req.body;

        if (!orderId) {
            return res.status(400).json({ message: "orderId is required" });
        }

        const requestId = orderId; // Using orderId as requestId for simplicity
        const requestType = "transactionStatus";

        // Signature Generation for Query
        const rawSignature =
            `accessKey=${config.accessKey}&orderId=${orderId}&partnerCode=${config.partnerCode}` +
            `&requestId=${requestId}`;

        const signature = crypto
            .createHmac('sha256', config.secretKey)
            .update(rawSignature)
            .digest('hex');

        const requestBody = {
            partnerCode: config.partnerCode,
            requestId: requestId,
            orderId: orderId,
            requestType: requestType,
            lang: "vi",
            signature: signature
        };

        console.log("Querying MoMo:", requestBody);

        // Note: Query endpoint is different usually, but for v2 it might be the same base URL with /query
        // Let's check the config.endpoint. It is .../create. Query is .../query.
        const queryEndpoint = "https://test-payment.momo.vn/v2/gateway/api/query";

        const response = await axios.post(queryEndpoint, requestBody);

        console.log("MoMo Query Response:", response.data);

        return res.status(200).json(response.data);

    } catch (error) {
        console.error("Query Error:", error.message);
        if (error.response) {
            console.error("MoMo Query Error Body:", error.response.data);
        }
        return res.status(500).json({
            message: "Internal Server Error",
            details: error.message
        });
    }
});

app.post('/momo/refund', async (req, res) => {
    try {
        const { orderId, amount, transId } = req.body;

        if (!orderId || !amount || !transId) {
            return res.status(400).json({ message: "orderId, amount, and transId are required" });
        }

        // Generate a NEW unique orderId for this refund transaction
        const refundOrderId = "REFUND" + new Date().getTime();
        const requestId = refundOrderId;
        const requestType = "refundMoMoWallet";
        const description = "Hoan tien don hang " + orderId;
        const amountStr = amount.toString();

        // Signature Generation for Refund
        // User instruction: accessKey, amount, description, orderId, partnerCode, requestId, transId
        // REMOVED: requestType
        const rawSignature =
            `accessKey=${config.accessKey}&amount=${amountStr}&description=${description}` +
            `&orderId=${refundOrderId}&partnerCode=${config.partnerCode}&requestId=${requestId}` +
            `&transId=${transId}`;

        console.log("Refund Raw Signature:", rawSignature);

        const signature = crypto
            .createHmac('sha256', config.secretKey)
            .update(rawSignature)
            .digest('hex');

        const requestBody = {
            partnerCode: config.partnerCode,
            requestId: requestId,
            orderId: refundOrderId,
            requestType: requestType,
            amount: amountStr,
            transId: transId.toString(), // Ensure string
            lang: "vi",
            description: description,
            signature: signature
        };

        console.log("Sending Refund to MoMo:", requestBody);

        const refundEndpoint = "https://test-payment.momo.vn/v2/gateway/api/refund";

        const response = await axios.post(refundEndpoint, requestBody);

        console.log("MoMo Refund Response:", response.data);

        return res.status(200).json(response.data);

    } catch (error) {
        console.error("Refund Error:", error.message);
        if (error.response) {
            console.error("MoMo Refund Error Body:", error.response.data);
        }
        return res.status(500).json({
            message: "Internal Server Error",
            details: error.message
        });
    }
});


app.listen(port, () => {
    console.log(`Backend running at http://localhost:${port}`);
});
