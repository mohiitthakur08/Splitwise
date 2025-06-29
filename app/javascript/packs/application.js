// app/javascript/packs/application.js

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "bootstrap/dist/js/bootstrap.bundle.min";


import "bootstrap"; // ✅ loads Bootstrap JS
import "jquery"; // ✅ loads jQuery globally

// ✅ load jGrowl manually from vendor folder
import "../../assets/stylesheets/jquery.jgrowl.min.js";

// ✅ load SCSS (this includes Bootstrap + jGrowl CSS)
import "../stylesheets/application.scss";

Rails.start();
Turbolinks.start();
ActiveStorage.start();
