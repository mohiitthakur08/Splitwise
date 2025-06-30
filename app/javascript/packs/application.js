// app/javascript/packs/application.js

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

// ✅ Bootstrap and jQuery
import "bootstrap/dist/js/bootstrap.bundle.min";
import "jquery";

// ✅ Load jGrowl JS from vendor folder
import "../../assets/stylesheets/jquery.jgrowl.min.js";

// ✅ Load SCSS (Bootstrap + jGrowl styles)
import "../stylesheets/application.scss";

// Start Rails JS utilities
Rails.start();
Turbolinks.start();
ActiveStorage.start();
