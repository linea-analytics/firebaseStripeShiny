# libraries         --------------------------------------------------------------------

library(shiny)
library(tidyverse)
library(httr)
library(firebase) # github
library(firebaseStripeShiny) # github

options(shiny.trace = F)
options(shiny.fullstacktrace = T)


# set up            --------------------------------------------------------------------

# FIREBASE
# for help on this: https://firebase.john-coene.com/guide/get-started/
Sys.setenv(FIREBASE_API_KEY = "xxx")
Sys.setenv(FIREBASE_PROJECT_ID = "xxx")
Sys.setenv(FIREBASE_AUTH_DOMAIN = "xxx")
Sys.setenv(FIREBASE_APP_ID = "xxx")
Sys.setenv(FIREBASE_STORAGE_BUCKET = "xxx")

tos_url = 'www.your_tos_page.com'
privacy_url = 'www.your_privacy_policy_page.com'


# STRIPE
# for help on this: https://stripe.com/docs/keys
Sys.setenv(STRIPE_SECRET_KEY = "xxx")
secret_key = Sys.getenv("STRIPE_SECRET_KEY")

# for help on this: https://stripe.com/docs/payments/checkout
purchase_plan_1_url = 'https://buy.stripe.com/xxxx'
purchase_plan_2_url = 'https://buy.stripe.com/xxxx'

price_id_1 = "xxx"
price_id_2 = "xxx"

# for help on this: https://stripe.com/docs/no-code/customer-portal
manage_plan_url = 'https://billing.stripe.com/p/login/xxxx'

# other options (optional)
info_email = 'xxx@xxx.xxx'

# ui                ####
ui = fluidPage(
  tags$head(useFirebase()),
  h1('firebaseStripeShiny'),
  sidebarLayout(
    sidebarPanel(
      reqSignin(
        actionButton(inputId = "signout", label = "sign out"),
        uiOutput('manage_plan_ui')
      ),
      uiOutput('user_name_ui'),
      em(
        'This is an example app to showcase how to integrate Firebase and Stripe, within a Shiny app in R.'
      )
    ),
    mainPanel(firebaseUIContainer(),
              uiOutput('content'))
    
  )
)



# server            ------------------------------------------------------------------
server = function(input, output, session) {
  # account               ----
  
  # FIREBASE
  
  # firebase login
  f = FirebaseUI$new("session")$set_providers(email = TRUE,
                                              google = TRUE)$set_tos_url(tos_url)$set_privacy_policy_url(privacy_url)$launch()
  
  # firebase signout button
  observeEvent(input$signout, {
    f$sign_out()
    reactiveData_has_plan(FALSE)
    reactiveData_sub_1(FALSE)
    reactiveData_sub_2(FALSE)
  })
  
  # firebase account email
  get_user_email = reactive({
    f$req_sign_in()
    user = f$get_signed_in()
    return(user$response$email)
  })
  output$user_name_ui = renderUI({
    if (reactiveData_has_plan()) {
      h3(paste0('You are logged in as ', get_user_email()))
    } else{
      h3("Login with Firebase to see plans.")
    }
  })
  
  # STRIPE
  
  #reactive value subscription status
  reactiveData_has_plan <- reactiveVal(FALSE)
  
  #reactive subscription subscription product
  reactiveData_sub_1 <- reactiveVal(FALSE)
  reactiveData_sub_2 <- reactiveVal(FALSE)
  
  # check if user has a plan plus product
  observeEvent(f$get_signed_in(), {
    has_plan = has_plan(email = get_user_email(),
                        secret_key = secret_key)
    has_plan_1 = has_plan_price(email = get_user_email(),
                                secret_key = secret_key,
                                price_id = price_id_1)
    has_plan_2 = has_plan_price(email = get_user_email(),
                                secret_key = secret_key,
                                price_id = price_id_2)
    
    reactiveData_has_plan(has_plan)
    reactiveData_sub_1(has_plan_1)
    reactiveData_sub_2(has_plan_2)
    
  })
  
  output$manage_plan_ui = renderUI({
    f$req_sign_in()
    
    has_plan = reactiveData_has_plan()
    
    if (has_plan) {
      a(
        class = 'manage_plan btn',
        href = paste0(manage_plan_url,
                      '?prefilled_email=',
                      get_user_email()),
        'manage plan',
        target = "_blank",
        rel = "noopener noreferrer"
      )
    }
  })
  
  output$content = renderUI({
    if (reactiveData_has_plan()) {
      tabsetPanel(
        # tab_1          --------------------------------------------------------------------
        tabPanel(title = 'Plan 1 Content', uiOutput("tab_1_ui")),
        # tab_2          --------------------------------------------------------------------
        tabPanel(title = 'Plan 2 Content', uiOutput("tab_2_ui"))
      )
    }
    else{
      div(
        h2('Plans'),
        a(
          href = paste0(
            purchase_plan_1_url,
            '?prefilled_email=',
            get_user_email()
          ),
          'Purchase plan 1'
        ),
        br(),
        a(
          href = paste0(
            purchase_plan_2_url,
            '?prefilled_email=',
            get_user_email()
          ),
          'Purchase plan 2'
        ),
        p(
          'For any query please reach out via ',
          a(href = paste0('mailto:', info_email), 'email.')
        )
      )
    }
  })
  
  # tab_1 & 2             ----
  output$tab_1_ui = renderUI({
    if (reactiveData_has_plan()) {
      if (reactiveData_sub_1()) {
        h1('This page is visible for you because you puchased "plan 1".')
      } else if (reactiveData_sub_2()) {
        h1('This page is only visible if you puchased "plan 1".')
      }
    }
  })
  output$tab_2_ui = renderUI({
    if (reactiveData_has_plan()) {
      if (reactiveData_sub_1()) {
        h1('This page is only visible if you puchased "plan 2".')
      } else if (reactiveData_sub_2()) {
        h1('This page is visible for you because you puchased "plan 2".')
      }
    }
  })
}

shinyApp(ui, server)
