pipeline {
    agent none

    stages {
        stage('TF init and apply') {
            agent {
                docker {
                    // The example TF code we use here only works in v0.13, however Cloudrail supports 0.14 as well.
                    image 'hashicorp/terraform:0.13.5'
                    args '-i --entrypoint=' // See https://stackoverflow.com/questions/52558150/jenkins-pipeline-docker-container-is-not-running
                }
            }
            steps {
                // Cloudrail requires a Terraform plan as an input, so we must create a plan first.
                withAWS(credentials: 'ea752f11-606a-4dba-827d-524b6772d674', region: 'us-east-1'){
                    // We're picking a specific test case to run against.
                    sh '''
                        cd test/aws/terraform/ec2_role_share_rule/public_and_private_ec2_same_role
                        terraform init
                        terraform plan -out=plan.out
                    '''

                    // We must stash the plan.out so it can be provided to the Cloudrail container
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
                // The "cloudrail run" command knows to look for this environment variable. Otherwise,
                // you can provide --api-key, but that may be written to the console logs.
                CLOUDRAIL_API_KEY = credentials('bdf6753e-05fe-47b2-9994-67e3ed4f2b9c')
            }
            steps {
                unstash 'PLAN_OUT'
                /**
                    This will run Cloudrail and produce regular text results. The idea is that if there are any rules
                    that are set to MANDATE, and they find violations, we will have "failed" tests in the textual output
                    and a non-zero exit code.
                    This will then cause Jenkins to stop the pipeline and list the failed results, allowing dev's to fix
                    the violations.
                    Note that Cloudrail has other output formats as well, such as Junit, which may be more appropriate in
                    many scenarios.
                    Also note that rules that are set to ADVISE (which is the default) will _not_ be included in the output by default.
                */
                sh '''
                    cd test/aws/terraform/ec2_role_share_rule/public_and_private_ec2_same_role
                    cloudrail run --directory . --tf-plan "plan.out" \
                      --origin ci --build-link "${BUILD_URL}"  --execution-source-identifier "${BUILD_NUMBER}"  \
                      --auto-approve
             '''
            }
        }
    }
}
