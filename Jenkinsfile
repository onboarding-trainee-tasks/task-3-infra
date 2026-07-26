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
                'PLAN',
                'APPLY',
                'DESTROY'
            ],
            description: 'Terraform action'
        )

        string(
            name: 'IMAGE_TAG',
            defaultValue: '',
            description: 'Tag created by the images Jenkins job'
        )

        booleanParam(
            name: 'CONFIRM_DESTROY',
            defaultValue: false,
            description: 'Must be enabled for DESTROY'
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
                    if (!params.IMAGE_TAG.trim()) {
                        error(
                            'IMAGE_TAG cannot be empty. ' +
                            'Use the tag produced by build-images.'
                        )
                    }

                    if (
                        params.ACTION == 'DESTROY' &&
                        !params.CONFIRM_DESTROY
                    ) {
                        error(
                            'Enable CONFIRM_DESTROY before DESTROY.'
                        )
                    }
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

                    terraform version
                    aws --version

                    echo "AWS identity:"
                    aws sts get-caller-identity
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

        stage('Terraform plan') {
            steps {
                sh '''
                    set -eu

                    if [ "$ACTION" = "DESTROY" ]; then
                        terraform plan \
                            -destroy \
                            -input=false \
                            -var="image_tag=$IMAGE_TAG" \
                            -out=tfplan
                    else
                        terraform plan \
                            -input=false \
                            -var="image_tag=$IMAGE_TAG" \
                            -out=tfplan
                    fi
                '''
            }
        }

        stage('Apply saved plan') {
            when {
                expression {
                    params.ACTION == 'APPLY' ||
                    params.ACTION == 'DESTROY'
                }
            }

            steps {
                sh '''
                    set -eu

                    terraform apply \
                        -input=false \
                        -auto-approve \
                        tfplan
                '''
            }
        }
    }

    post {
        success {
            echo (
                "Terraform ${params.ACTION} completed successfully."
            )
        }

        always {
            cleanWs(
                deleteDirs: true,
                disableDeferredWipeout: true
            )
        }
    }
}