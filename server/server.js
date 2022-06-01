let express = require('express');
let path = require('path');
let cookieParser = require('cookie-parser');
let logger = require('morgan');
var cors = require('cors');
const dotenv = require('dotenv');
const auth = require('./middleware/auth.middleware')
dotenv.config();
let indexRouter = require('./routes/index');
let accountApiRouter = require('./api/account.api');
let earnApiRouter = require('./api/earn.api');

let app = express();

//middlewares
app.use(cors());
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(auth.accountCheck)

//routes
app.use('/general', indexRouter);
app.use('/api/account', accountApiRouter)
app.use('/api/earn', earnApiRouter)

let port = 3000
app.listen(port, () => {
    console.log(`Listening on port ${port}`)
    console.log("try it out on", "http://localhost:3000");
  })
