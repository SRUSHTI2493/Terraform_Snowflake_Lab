#  :snowflake: Database Change Management with Terraform and GitHub
In my previous role, I worked on automating Snowflake database change management using Terraform and GitHub Actions. The aim was to remove manual database setup and ensure consistent, version-controlled deployments. I wrote Terraform code to create Snowflake databases and schemas and used Terraform Cloud for remote state management and secure credential storage. I also built a GitHub Actions CI/CD pipeline that validates and applies changes automatically whenever code is pushed. This helped improve deployment reliability, reduce manual errors, and made changes easy to track and roll back
##  Prerequisites
This quickstart assumes that you have a basic working knowledge of Git repositories.

##  :arrow_down: What You'll Learn
1. A brief history and overview of GitHub Actions
 
2. A brief history and overview of Terraform and Terraform Cloud
 
3. How database change management tools like Terraform work
 
4. How a simple release pipeline works
 
5. How to create CI/CD pipelines in GitHub Actions
  
6. Ideas for more advanced CI/CD pipelines with stages
 
7.  How to get started with branching strategies
  
8. How to get started with testing strategies

## What You'll Need

:small_blue_diamond: Snowflake

:small_blue_diamond: A Snowflake Account.

:small_blue_diamond: A Snowflake User created with appropriate permissions. This user will need permission to create databases.

:small_blue_diamond: GitHub

:small_blue_diamond: A GitHub Account. If you don't already have a GitHub account you can create one for free. Visit the Join GitHub page to get started.

:small_blue_diamond: A GitHub Repository. If you don't already have a repository created, or would like to create a new one, then Create a new respository. For the type, select Public (although you could use either). And you can skip adding the README, .gitignore and license for now.

:small_blue_diamond: Terraform Cloud

:small_blue_diamond: A Terraform Cloud Account. If you don't already have a Terraform Cloud account you can create on for free. Visit the Create an account page to get started.

:small_blue_diamond: Integrated Development Environment (IDE)

:small_blue_diamond:Your favorite IDE with Git integration. If you don't already have a favorite IDE that integrates with Git I would recommend the great, free, open-source Visual Studio Code.
Your project repository cloned to your computer. For connection details about your Git repository, open the Repository and copy the HTTPS link provided near the top of the page. If you have at least one file in your repository then click on the green Code icon near the top of the page and copy the HTTPS link. Use that link in VS Code or your favorite IDE to clone the repo to your computer.
## :trophy: What You'll Build
A simple, working release pipeline for Snowflake in GitHub Actions using Terraform

##  Setup and Configure Terraform Cloud
### Create a new Workspace
From the Workspaces page click on the "+ New workspace" button near the top right of the page. On the first page, where it asks you to choose the type of workflow, select "API-driven workflow".

![image](https://github.com/SRUSHTI2493/Terraform_Snowflake_Lab/assets/87080882/b48bcbd6-cee0-47fe-9712-df5b359b79ff)

On the second page, where it asks for the "Workspace Name" enter gh-actions-demo and then click the "Create workspace" button at the bottom of the page.

### Setup Environment Variables
In order for Terraform Cloud to be able to connect to your Snowflake account you'll need to store the settings in Environment variables. Fortunately, Terraform Cloud makes this easy. From your new workspace homepage click on the "Variables" tab. Then for each variable listed below click on "+ Add variable" button (under the "Environment Variables" section) and enter the name given below along with the appropriate value (adjusting as appropriate).

<img width="307" alt="image" src="https://github.com/SRUSHTI2493/Terraform_Snowflake_Lab/assets/87080882/f57170e8-dd8c-4661-a02d-c09cc2c03b8a">

:o: Tip - For more details on the supported arguments please check out the CZI Terraform Provider for Snowflake documentation.

When you're finished adding all the secrets, the page should look like this:

![image](https://github.com/SRUSHTI2493/Terraform_Snowflake_Lab/assets/87080882/5e5c8fdf-9d42-4398-8440-74a75aa4fa5a)

### Create an API Token
The final thing we need to do in Terraform Cloud is to create an API Token so that GitHub Actions can securely authenticate with Terraform Cloud. Click on your user icon near the top right of the screen and then click on "User settings". Then in the left navigation bar click on the user settings page click on the "Tokens" tab.

Click on the "Create an API token" button, give your token a "Description" (like GitHub Actions) and then click on the "Create API token" button. Pay careful attention on the next screen. You need to save the API token because once you click on the "Done" button the token will not be displayed again. Once you've saved the token, click the "Done" button.

### Create the Actions Workflow
#### Create Actions Secrets
Action Secrets in GitHub are used to securely store values/variables which will be used in your CI/CD pipelines. In this step we will create a secret to store the API token to Terraform Cloud.

From the repository, click on the "Settings" tab near the top of the page. From the Settings page, click on the "Secrets" tab in the left hand navigation. The "Actions" secrets should be selected.

Click on the "New repository secret" button near the top right of the page. For the secret "Name" enter TF_API_TOKEN and for the "Value" enter the API token value you saved from the previous step.

#### Action Workflows
Action Workflows represent automated pipelines, which inludes both build and release pipelines. They are defined as YAML files and stored in your repository in a directory called .github/workflows. In this step we will create a deployment workflow which will run Terraform and deploy changes to our Snowflake account.

From the repository, click on the "Actions" tab near the top middle of the page. 
Click on the "set up a workflow yourself ->" link (if you already have a workflow defined click on the "new workflow" button and then the "set up a workflow yourself ->" link)
On the new workflow page
Name the workflow snowflake-terraform-demo.yml
In the "Edit new file" box, replace the contents with the the following:
 name: "Snowflake Terraform Demo Workflow"

on:
  push:
    branches:
      - main

jobs:
  snowflake-terraform-demo:
    name: "Snowflake Terraform Demo Job"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

      - name: Terraform Format
        id: fmt
        run: terraform fmt -check

      - name: Terraform Init
        id: init
        run: terraform init

      - name: Terraform Validate
        id: validate
        run: terraform validate -no-color

      - name: Terraform Apply
        id: apply
        run: terraform apply -auto-approve


Finally, click on the green "Start commit" button near the top right of the page and then click on the green "Commit new file" in the pop up window (you can leave the default comments and commit settings). You'll now be taken to the workflow folder in your repository.

A few things to point out from the YAML pipeline definition:

The on: definition configures the pipeline to automatically run when a change is pushed on the main branch of the repository. So any change committed in a different branch will not automatically trigger the workflow to run.
Please note that if you are re-using an existing GitHub repository it might retain the old master branch naming. If so, please update the YAML above (see the on: section).
We're using the default GitHub-hosted Linux agent to execute the pipeline.

### Create Your First Database Migration
Open up your cloned GitHub repository in your favorite IDE and create a new file in the root named main.tf with the following contents. Please be sure to replace the organization name with your Terraform Cloud organization name.

terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.17"
    }
  }

  backend "remote" {
    organization = "my-organization-name"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}

provider "snowflake" {
}

resource "snowflake_database" "demo_db" {
  name    = "DEMO_DB"
  comment = "Database for Snowflake Terraform demo"
}

### Confirm Changes Deployed to Snowflake
By now your first database migration should have been successfully deployed to Snowflake, and you should now have a DEMO_DB database available. There a few different places that you should check to confirm that everything deployed successfully, or to help you debug in the event that an error happened.

#### GitHub Actions Log
From your repository in GitHub, click on the "Actions" tab. If everything went well, you should see a successful workflow run listed. But either way you should see the run listed under the "All workflows". To see details about the run click on the run name. From the run overview page you can further click on the job name (it should be Snowflake Terraform Demo Job) in the left hand navigation bar or on the node in the yaml file viewer. Here you can browse through the output from the various steps. In particular you might want to review the output from the Terraform Apply step.

![image](https://github.com/SRUSHTI2493/Terraform_Snowflake_Lab/assets/87080882/51b3a020-6c4e-4362-a3c9-182e0c47ccea)

#### Terraform Cloud Log

While you'll generally be able to see all the Terraform output in the GitHub Actions logs, you may need to also view the logs on Terraform Cloud. From your Terraform Cloud Workspace, click on the "Runs" tab. Here you will see each run listed out, and for the purposes of this quickstart, each run here corresponds to a run in GitHub Actions. Click on the run to open it and view the output from the various steps.

![image](https://github.com/SRUSHTI2493/Terraform_Snowflake_Lab/assets/87080882/4eb42ad4-4eb7-49f7-9fc4-26383e4335d5)

#### Snowflake Objects
Log in to your Snowflake account and you should see your new DEMO_DB database! Additionaly you can review the queries that were executed by Terraform by clicking on the "History" tab at the top of the window.


#### Create Your Second Database Migration
Now that we've successfully deployed our first change to Snowflake, it's time to make a second one. This time we will add a schema to the DEMO_DB and have it deployed through our automated pipeline.

Open up your cloned repository in your favorite IDE and edit the main.tf file by appending the following lines to end of the file:

resource "snowflake_schema" "demo_schema" {
  database = snowflake_database.demo_db.name
  name     = "DEMO_SCHEMA"
  comment  = "Schema for Snowflake Terraform demo"
}

:medal_military: <img width="255" alt="image" src="https://github.com/SRUSHTI2493/Terraform_Snowflake_Lab/assets/87080882/1edfbb38-46a3-4428-94a8-71acfc243ff7">
