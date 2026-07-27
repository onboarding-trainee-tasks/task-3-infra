pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: [
                'APPLY',
                'DESTROY'
            ],
            description: 'Terraform action'
        )

        booleanParam(
            name: 'CONFIRM_ACTION',
            defaultValue: false,
            description: 'Required for both APPLY and DESTROY'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')

        AWS_REGION = 'eu-central-1'
        AWS_DEFAULT_REGION = 'eu-central-1'

        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }

    stages {
        stage('Check parameters') {
            steps {
                script {
                    if (!params.CONFIRM_ACTION) {
                        error(
                            "Enable CONFIRM_ACTION before " +
                            "${params.ACTION}."
                        )
                    }

                    currentBuild.description = params.ACTION
                }
            }
        }

        stage('Check environment') {
            steps {
                sh '''
                    set -eu

                    echo "Current user:"
                    whoami

                    echo "Current workspace:"
                    pwd

                    echo "Current branch:"
                    echo "${BRANCH_NAME:-not-multibranch}"

                    terraform version
                    aws --version

                    echo "AWS identity:"
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Show image tags') {
            steps {
                sh '''
                    set -eu

                    echo "Image tags used by Terraform:"
                    cat image-tags.tfvars
                '''
            }
        }

        stage('Terraform init') {
            steps {
                sh '''
                    set -eu

                    terraform init \
                        -input=false
                '''
            }
        }

        stage('Terraform format check') {
            steps {
                sh '''
                    set -eu

                    terraform fmt \
                        -check \
                        -recursive
                '''
            }
        }

        stage('Terraform validate') {
            steps {
                sh '''
                    set -eu

                    terraform validate
                '''
            }
        }

        stage('Create Terraform plan') {
            steps {
                sh '''
                    set -eu

                    if [ "$ACTION" = "DESTROY" ]; then
                        terraform plan \
                            -destroy \
                            -input=false \
                            -out=tfplan
                    else
                        terraform plan \
                            -input=false \
                            -out=tfplan
                    fi
                '''
            }
        }

        stage('Show Terraform plan') {
            steps {
                sh '''
                    set -eu

                    terraform show \
                        -no-color \
                        tfplan
                '''
            }
        }

        stage('Apply saved plan') {
            steps {
                sh '''
                    set -eu

                    terraform apply \
                        -input=false \
                        tfplan
                '''
            }
        }
    }

    post {
        success {
            echo (
                "Terraform ${params.ACTION} " +
                "completed successfully."
            )
        }

        failure {
            echo 'Terraform Pipeline failed. Check the error above.'
        }

        cleanup {
            script {
                if (getContext(hudson.FilePath)) {
                    cleanWs(
                        deleteDirs: true,
                        disableDeferredWipeout: true
                    )
                } else {
                    echo 'Workspace was not allocated. Cleanup skipped.'
                }
            }
        }
    }
}