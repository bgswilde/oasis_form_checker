const functions = require("firebase-functions");
const cors = require("cors")({origin: true});
const admin = require("firebase-admin");
admin.initializeApp();

exports.getJsonKey = functions.https.onRequest((req, res) => {
  const jsonKey = process.env.JSON_KEY;
  res.status(200).json(jsonKey);
});

exports.getGoogleClient = functions.https.onRequest((req, res) => {
  const gClient = process.env.GOOGLE_CLIENT;
  res.status(200).json(gClient);
});

exports.getRangeRequest = functions.https.onRequest((req, res) => {
  const range = process.env.RANGE;
  res.status(200).json(range);
});

exports.getGoogleSheet = functions.https.onRequest((req, res) => {
  const gSheet = process.env.GOOGLE_SHEET;
  res.status(200).json(gSheet);
});

// exports.getGoogleSheetD = functions.https.onRequest((req, res) => {
//   cors(req, res, () => {
//     console.log("config", JSON.stringify(functions.config()));
//     console.log("env", JSON.stringify(functions.config().env));
//     const gSheet = functions.config().env.GOOGLE_SHEET;
//     console.log(gSheet);
//     res.status(200).json({"gSheet": gSheet});
//     console.log(res);
//   });
// });

// exports.getJsonKeyD = functions.https.onRequest((req, res) => {
//   cors(req, res, () => {
//     console.log("config", JSON.stringify(functions.config()));
//     console.log("env", JSON.stringify(functions.config().env));
//     const jsonKey = functions.config().env.JSON_KEY;
//     console.log(jsonKey);
//     res.status(200).json({"jsonKey": jsonKey});
//     console.log(res);
//   });
// });

// exports.getGoogleClientD = functions.https.onRequest((req, res) => {
//   cors(req, res, () => {
//     console.log("config", JSON.stringify(functions.config()));
//     console.log("env", JSON.stringify(functions.config().env));
//     const gClient = functions.config().env.GOOGLE_CLIENT;
//     console.log(gClient);
//     res.status(200).json({"gClient": gClient});
//     console.log(res);
//   });
// });

// exports.getRangeRequestD = functions.https.onRequest((req, res) => {
//   cors(req, res, () => {
//     console.log("config", JSON.stringify(functions.config()));
//     console.log("env", JSON.stringify(functions.config().env));
//     const range = functions.config().env.RANGE;
//     console.log(range);
//     res.status(200).json({"range": range});
//     console.log(res);
//   });
// });

exports.getGoogleSheetE = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const gSheet = process.env.GOOGLE_SHEET;
    console.log(gSheet);
    res.status(200).json({"gSheet": gSheet});
    console.log(res);
  });
});

exports.getJsonKeyE = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const jsonKey = process.env.JSON_KEY;
    console.log(jsonKey);
    res.status(200).json({"jsonKey": jsonKey});
    console.log(res);
  });
});

exports.getGoogleClientE = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const gClient = process.env.GOOGLE_CLIENT;
    console.log(gClient);
    res.status(200).json({"gClient": gClient});
    console.log(res);
  });
});

exports.getRangeRequestE = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const range = process.env.RANGE;
    console.log(range);
    res.status(200).json({"range": range});
    console.log(res);
  });
});
// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
