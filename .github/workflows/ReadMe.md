**_GITHUB ACTION CONFIGURATION FILES_**

These files are used to configure GitHub Actions, which are automated workflows that can be triggered by various events.

These workflows can perform a variety of tasks, including building and testing code, deploying applications, and more.

The integrationtest.yml file is used to configure a workflow that runs integration tests on the code. This workflow is triggered by push

The infrastructe.yml file is used to define the workflow for deployment. It specifies the events that trigger the workflow, the jobs that are run, and the steps that are performed in each job. This workflow is triggered by worflow_run: LocalStack Terraform Integration Test

The files can be mereged into one workflow, however, this is not reccommended for larger scale projects and may result in fat pipelines or readability issues as the infrastrute demands develop.
