pipeline {
    agent any

    parameters {
        choice(
            name: 'SERVICE_TYPE',
            choices: ['postgresql_flexible_server', 'app_service', 'virtual_machine'],
            description: 'Azure service to provision'
        )
        string(
            name: 'TFVARS_GIT_URL',
            defaultValue: 'https://github.com/<your-org>/<your-tfvars-repo>.git',
            description: 'Git repo that holds the .tfvars files'
        )
        string(
            name: 'TFVARS_BRANCH',
            defaultValue: 'main',
            description: 'Branch of the tfvars repo'
        )
        string(
            name: 'TFVARS_PATH',
            defaultValue: 'dev/postgresql-dev.tfvars',
            description: 'Path of the .tfvars file inside that repo'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action'
        )
    }

    environment {
        // Jenkins "Secret text" credentials for the Azure service principal
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')

        // Storage account that holds Terraform state (create once, manually)
        TFSTATE_RG        = 'rg-terraform-state'
        TFSTATE_SA        = 'tfstateabhijit001'   // your actual storage account name
        TFSTATE_CONTAINER = 'tfstate'

        TF_IN_AUTOMATION = 'true'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout Terraform code') {
            steps {
                checkout scm
            }
        }

        stage('Checkout tfvars repo') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.TFVARS_BRANCH}"]],
                    userRemoteConfigs: [[
                        url: params.TFVARS_GIT_URL,
                        credentialsId: 'github-credentials'
                    ]],
                    extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'tfvars-repo']]
                ])
                script {
                    env.TFVARS_FILE = "${env.WORKSPACE}/tfvars-repo/${params.TFVARS_PATH}"
                    env.TF_DIR      = "${env.WORKSPACE}/terraform/${params.SERVICE_TYPE}"
                    // state key = service + tfvars file name, so each env gets its own state
                    def base = params.TFVARS_PATH.tokenize('/').last().replace('.tfvars', '')
                    env.STATE_KEY = "${params.SERVICE_TYPE}/${base}.tfstate"
                }
                sh 'test -f "$TFVARS_FILE" || { echo "tfvars file not found: $TFVARS_FILE"; exit 1; }'
            }
        }

        stage('Terraform Init') {
            steps {
                dir(env.TF_DIR) {
                    sh '''
                        terraform init -input=false \
                          -backend-config="resource_group_name=$TFSTATE_RG" \
                          -backend-config="storage_account_name=$TFSTATE_SA" \
                          -backend-config="container_name=$TFSTATE_CONTAINER" \
                          -backend-config="key=$STATE_KEY"
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir(env.TF_DIR) {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir(env.TF_DIR) {
                    script {
                        def destroyFlag = (params.ACTION == 'destroy') ? '-destroy' : ''
                        def planCmd = "terraform plan -input=false ${destroyFlag} -var-file=\"\$TFVARS_FILE\" -out=tfplan"

                        if (params.SERVICE_TYPE == 'postgresql_flexible_server') {
                            // DB admin password is kept in Jenkins, not in Git
                            withCredentials([string(credentialsId: 'pg-admin-password', variable: 'TF_VAR_administrator_password')]) {
                                sh planCmd
                            }
                        } else {
                            sh planCmd
                        }
                    }
                }
            }
        }

        stage('Approval') {
            when { expression { params.ACTION in ['apply', 'destroy'] } }
            steps {
                input message: "Run '${params.ACTION}' for ${params.SERVICE_TYPE} using ${params.TFVARS_PATH}?",
                      ok: 'Proceed'
            }
        }

        stage('Terraform Apply / Destroy') {
            when { expression { params.ACTION in ['apply', 'destroy'] } }
            steps {
                dir(env.TF_DIR) {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
    }

    post {
        always {
            dir(env.TF_DIR ?: '.') {
                sh 'rm -f tfplan || true'
            }
        }
    }
}
