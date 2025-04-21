// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// import NavToggleController from "./nav_toggle_controller"
// import MenuHorizontalController from "./menu_horizontal_controller"
// import CardController from "./card_controller"
// import SearchController from "./search_controller"
// import FullscreenController from "./fullscreen_controller"
// import TodoController from "./todo_controller"
// import ActiveMenuController from "./active_menu_controller"
// import PreloaderController from "./preloader_controller"
// import MobileNavController from "./mobile_nav_controller"

// application.register("nav-toggle", NavToggleController)
// application.register("menu-horizontal", MenuHorizontalController)
// application.register("card", CardController)
// application.register("search", SearchController)
// application.register("fullscreen", FullscreenController)
// application.register("todo", TodoController)
// application.register("active-menu", ActiveMenuController)
// application.register("preloader", PreloaderController)
// application.register("mobile-nav", MobileNavController)
