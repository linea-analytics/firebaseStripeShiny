# Saas with Shiny, Firebase, and Stripe
 
![thumbnail](https://raw.githubusercontent.com/linea-analytics/public/main/img/firebaseStripeShiny.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:Alpha](https://img.shields.io/badge/Lifecycle-Alpha-7e7E00)](https://r-pkg.org/pkg/linea)

This repo shows how to implement a subscription service (SaaS) with R **Shiny**, **Firebase**, and **Stripe**, using the R library `firebaseStripeShiny`.

### Pre-requisites:
- Familiarity with [R](https://www.r-project.org/) & [Shiny](https://shiny.posit.co/)
- Some familiarity with [APIs](https://www.w3schools.com/js/js_api_intro.asp) & [HTTP](https://www.w3schools.com/whatis/whatis_http.asp)

### Recommendations
- If you are unfamiliar with Firebase, I would suggest trying to use it, without Stripe, to get use to how it works. You can find the necessary information [here](https://firebase.john-coene.com/).

- The same goes for APIs and the `httr` package, which allows R to handle HTTP requests. You can learn about `httr` [here](https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html). 

---

### Installation
You can install firebaseStripeShiny with the following function from `devtools`:
```
devtools::install_github("linea-analytics/firebaseStripeShiny")
```

---

### How does this work?
If you have an R Shiny app that you would like to sell as a service to customers, you can do so using Firebase and Stripe.
- [Firebase](https://firebase.google.com/) is a service (owned by Google) that helps manage **user authentication**.
    - Luckily, there is an existing R package that simplifies using Firebase in shiny. The package can be found [here](https://firebase.john-coene.com/).
- [Stripe](https://stripe.com/gb) is a payment process platform that can help manage **subscriptions**.
    - Stripe provides pre-built interfaces for managing payments as well as an API which is relatively easy to use.

The `R/stripe_functions.R` file contains simple functions that leverage the Stripe API to compare your Firebase users to the list of those who paid for a subscription (your Stripe customers).

For this implementation, some functions assumes there are two subscriptions (e.g. monthly, yearly) but the same approach should work for any number of products.

---

### What do I use this?
The `app.R` file contains a basic Shiny app with:
- [Firebase](https://firebase.google.com/) sign-in & sign-out (user accounts)
- [Stripe](https://stripe.com/gb) sing-up to plan & manage current plan (subscriptions)
- Conditional content 
    - Shown based on whether the user is signed in and has purchased a subscription.

The only edits needed for this to work are the identifying informations for the Firebase and Stripe APIs. Once you filled the lines below, found in the example app below: 

```r
# FIREBASE ----
# for help on this: https://firebase.john-coene.com/guide/get-started/
Sys.setenv(FIREBASE_API_KEY = "xxx")
Sys.setenv(FIREBASE_PROJECT_ID = "xxx")
Sys.setenv(FIREBASE_AUTH_DOMAIN = "xxx")
Sys.setenv(FIREBASE_APP_ID = "xxx")
Sys.setenv(FIREBASE_STORAGE_BUCKET = "xxx")

tos_url = 'www.your_tos_page.com'
privacy_url = 'www.your_privacy_policy_page.com' 


# STRIPE ----
# for help on this: https://stripe.com/docs/keys
Sys.setenv(STRIPE_SECRET_KEY = "xxx")

# for help on this: https://stripe.com/docs/payments/checkout
purchase_plan_1_url = 'xxx'
purchase_plan_2_url = 'xxx'

# for help on this: https://stripe.com/docs/no-code/customer-portal
manage_plan_url = 'xxx'

# other options (optional)
info_email = 'xxx@xxx.com'

```

### Example App

Full app code:
```r
# libraries         --------------------------------------------------------------------

library(httr)
library(firebase) # github
library(shiny)
library(firebaseStripeShiny)

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

# for help on this: https://stripe.com/docs/payments/checkout
purchase_plan_1_url = 'xxx'
purchase_plan_2_url = 'xxx'

plan_1_product <- "xxx"
plan_2_product <- "xxx"

# for help on this: https://stripe.com/docs/no-code/customer-portal
manage_plan_url = 'xxx'

# other options (optional)
info_email = 'xxx@xxx.com'

# ui                ####
ui =fluidPage(
  
  # header
  reqSignin(uiOutput('user_name_ui')),
  reqSignin(actionButton(inputId = "signout",label = "sign out")),
  
  # content
  h1('test-app'),
  tabsetPanel(# tab_0          --------------------------------------------------------------------
              tabPanel(title = 'tab 0', 
                       div(
                         useFirebase(),
                         firebaseUIContainer(),
                         uiOutput('tab_0_ui')
                       )
              ),
              # tab_1          --------------------------------------------------------------------
              tabPanel(title = 'tab 1', uiOutput("tab_1_ui")),
              # tab_2          --------------------------------------------------------------------
              tabPanel(title = 'tab 2', uiOutput("tab_2_ui"))
  )
)



# server            ------------------------------------------------------------------
server = function(input, output, session) {
  
  # account               ----
  
  # firebase login
  f = FirebaseUI$new("session")$
    set_providers(
      email = TRUE,
      google = TRUE
    )$
    set_tos_url(tos_url)$
    set_privacy_policy_url(privacy_url)$
    launch()
  
  # firebase signout button
  observeEvent(input$signout, {
    f$sign_out()
  })
  
  # firebase account email
  get_user_email = reactive({
    f$req_sign_in()
    user = f$get_signed_in()
    return(user$response$email)
  })
  output$user_name_ui = renderUI({
    h3(paste0('You are logged in as ',get_user_email()))
  })
  
  # stripe
  
  #reactive value subscription status
  reactiveData_has_plan <- reactiveVal(NULL)
  
  #reactive subscription subscription product 
  reactiveData_sub_prod <- reactiveVal(NULL)
  
  # check if user has a plan plus product
  observeEvent(f$get_signed_in(), {
    
    user = f$get_signed_in() # get logged in user info
    has_plan_prod = user_has_plan_prod(email = user$response$email, secret_key = secret_key)
    
    if (has_plan_prod$has_plan) {
      
      reactiveData_has_plan(has_plan_prod$has_plan)
      
      reactiveData_sub_prod(has_plan_prod$content_sub_prod)
      
    }
    
  })
  
  output$manage_plan_ui = renderUI({
    f$req_sign_in()
    
    has_plan = has_plan()
    
    if (has_plan) {
      a(
        class = 'manage_plan btn',
        href = paste0(
          manage_plan_url,
          '?prefilled_email=',
          user$response$email
        ),
        'manage plan',
        target = "_blank",
        rel = "noopener noreferrer"
      )
    }
  })
  
  # tab_0                 ----
  
  output$tab_0_ui = renderUI({
    f$req_sign_in()
    
    has_plan = has_plan() 
    
    if (has_plan) {
      tagList(
        h1('You are in!'),
        uiOutput('manage_plan_ui')
      )
      
    } else{
      div(
        h2('Plans'),
        a(
          href = paste0(
            purchase_plan_1_url,
            '?prefilled_email=',
            user$response$email
          ),
          'purchase'
        ),
        br(),
        a(
          href = paste0(
            purchase_plan_2_url,
            '?prefilled_email=',
            user$response$email
          ),
          'purchase'
        ),
        p('For any query please reach out via ',
          a(href = paste0(
            'mailto:', info_email
          ), 'email.'))
      )
    }
    
  })
  
  # tab_1 & 2             ----
  output$tab_1_ui = renderUI({
    h1('This is tab 1.')
    # FREE CONTENT HERE
  })
  output$tab_2_ui = renderUI({
    f$req_sign_in()
    
    has_plan = user_has_plan() && plan_2_product == sub_prod() 
    
    if (has_plan) {
      h1('Secret tab 2 content of product 2.')
      # PAID CONTENT HERE
    }else{
      h1('You need to purchase a plan and product 2 to see this content.')
      # FREE CONTENT HERE
    }
  })
}

shinyApp(ui, server)

```