
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['PLAN', 'APPLY', 'DESTROY'],
            description: 'Terraform operation'
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
        stage('Check environment') {
            steps {
                script {
                    currentBuild.description = params.ACTION
                }

                sh '''
                    set -eu

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
                    cat image-tags.auto.tfvars
                '''
            }
        }

        stage('Terraform init') {
            steps {
                sh '''
                    set -eu

                    terraform init -input=false
                '''
            }
        }

        stage('Terraform format check') {
            steps {
                sh '''
                    set -eu

                    terraform fmt -check -recursive
                '''
            }
        }

        stage('Terraform validate') {
            steps {
                sh '''
                    set -eu

                    terraform validate -no-color
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
                            -no-color \
                            -lock-timeout=5m \
                            -out=tfplan
                    else
                        terraform plan \
                            -input=false \
                            -no-color \
                            -lock-timeout=5m \
                            -out=tfplan
                    fi
                '''
            }
        }

        stage('Show Terraform plan') {
            steps {
                sh '''
                    terraform show -no-color tfplan
                '''
            }
        }

        stage('Approve Terraform plan') {
            when {
                expression {
                    params.ACTION != 'PLAN'
                }
            }

            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    input(
                        message: "Approve ${params.ACTION} of the saved Terraform plan?",
                        ok: "Approve ${params.ACTION}"
                    )
                }
            }
        }

        stage('Apply saved plan') {
            when {
                expression {
                    params.ACTION != 'PLAN'
                }
            }

            steps {
                sh '''
                    set -eu

                    terraform apply \
                        -input=false \
                        -lock-timeout=5m \
                        tfplan
                '''
            }
        }
    }

    post {
        success {
            echo "Terraform ${params.ACTION} completed successfully."
        }

        failure {
            echo 'Terraform pipeline failed. Check the logs.'
        }

        aborted {
            echo 'Terraform pipeline was aborted.'
        }

        cleanup {
            script {
                if (getContext(hudson.FilePath)) {
                    cleanWs(
                        deleteDirs: true,
                        disableDeferredWipeout: true
                    )
                }
            }
        }
    }
}
