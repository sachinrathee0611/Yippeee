pipeline {
    agent any

    // Satisfies Step 7.3: "create environment block and use custom variables with values"
    environment {
        // --- UPDATE THESE VARIABLES ---
        DOCKER_HUB_CREDS = 'dockerhub-credentials' // ID of the credentials you create in Jenkins
        DOCKER_REPO      = 'sachinrathee061101/new-app'   // Your Docker Hub username and repository name
        S3_BUCKET_NAME   = 'jenkins-bucket-16'
        APP_PORT         = '80' 
        // ------------------------------
        
        // This will be populated dynamically during the pipeline run
        EC2_PUBLIC_IP    = '' 
    }

    stages {
        stage('1. Clone Repository') {
            steps {
                // When you configure "Pipeline script from SCM" in Jenkins, 
                // this step explicitly checks out the code from your webhook-triggered repo.
                checkout scm
            }
        }

        stage('2. Upload to S3') {
            steps {
                // Uses the "Pipeline: AWS Steps" plugin to upload the workspace files
                // Relies on the IAM Instance Profile attached to the EC2 instance for permissions
                s3Upload(bucket: "${S3_BUCKET_NAME}", includePathPattern: '**/*', path: "builds/build-${env.BUILD_ID}/")
            }
        }

        stage('3. Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image with tag: ${env.BUILD_ID}"
                    // Creates the image tagging it with the Jenkins auto-generated BUILD_ID
                    sh "docker build -t ${DOCKER_REPO}:${env.BUILD_ID} ."
                }
            }
        }

        stage('4. Push to Docker Hub') {
            steps {
                script {
                    // Authenticates securely using Jenkins stored credentials, then pushes
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_REPO}:${env.BUILD_ID}"
                    }
                }
            }
        }

        stage('5. Deploy Container') {
            steps {
                script {
                    // Removes any older version of the container if it exists so the port is free
                    sh "docker stop live-webapp || true"
                    sh "docker rm live-webapp || true"

                    // Runs the new container in detached mode, binding the port
                    sh "docker run -d -p ${APP_PORT}:80 --name live-webapp ${DOCKER_REPO}:${env.BUILD_ID}"
                }
            }
        }
        
        stage('Gather Network Data') {
            steps {
                script {
                    // Dynamically fetches the EC2 public IP using AWS Instance Metadata
                    env.EC2_PUBLIC_IP = sh(script: "curl -s http://169.254.169.254/latest/meta-data/public-ipv4", returnStdout: true).trim()
                }
            }
        }
    }

    // Satisfies Step 7.6: "Get notified"
    post {
        success {
            mail to: 'sahilrathee250@gmail.com',
                 subject: "✅ SUCCESS: WebApp Deployment Build #${env.BUILD_ID}",
                 body: """The deployment pipeline completed successfully!
                 
Application is now live and accessible at:
http://${env.EC2_PUBLIC_IP}:${APP_PORT}

Docker Image Deployed: ${DOCKER_REPO}:${env.BUILD_ID}"""
        }
        
        failure {
            mail to: 'sachinrathee250@gmail.com',
                 subject: "❌ FAILURE: WebApp Deployment Build #${env.BUILD_ID}",
                 body: """The pipeline failed during execution.
                 
Please log into the Jenkins dashboard and check the console output for Build #${env.BUILD_ID} to diagnose the error."""
        }
    }
}
