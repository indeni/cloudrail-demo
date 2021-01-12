pipeline {
    agent none

    stages {
        stage('TF init and apply') {
            agent {
                docker {
                    image 'hashicorp/terraform:0.13.5'
                    args '-i --entrypoint=' // See https://stackoverflow.com/questions/52558150/jenkins-pipeline-docker-container-is-not-running
                }
            }
            steps {
                withAWS(credentials: 'ea752f11-606a-4dba-827d-524b6772d674', region: 'us-east-1'){
                    sh '''
                        cd test/aws/terraform/ec2_role_share_rule/public_and_private_ec2_same_role
                        terraform init
                        terraform plan -out=plan.out
                    '''
                    stash includes: 'test/aws/terraform/ec2_role_share_rule/public_and_private_ec2_same_role/**', name: 'PLAN_OUT'
                }
            }
        }
        stage('Cloudrail') {
            agent {
                docker {
                    image 'indeni/cloudrail-cli:latest'
                    args '-i --entrypoint=' // See https://stackoverflow.com/questions/52558150/jenkins-pipeline-docker-container-is-not-running
                }
            }
            environment {
                CLOUDRAIL_API_KEY = credentials('bdf6753e-05fe-47b2-9994-67e3ed4f2b9c')
            }
            steps {
                unstash 'PLAN_OUT'
                sh '''
                    cd test/aws/terraform/ec2_role_share_rule/public_and_private_ec2_same_role
                    cloudrail run --directory . --tf-plan "plan.out" \
                      --origin ci --build-link "${BUILD_URL}"  --execution-source-identifier "${BUILD_NUMBER}"  \
                      --api-key "$CLOUDRAIL_API_KEY" \
                      --auto-approve
             '''
            }
        }
    }
}
