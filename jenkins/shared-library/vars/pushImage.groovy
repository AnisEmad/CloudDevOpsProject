def call(Map args = [:]) {
    def localImage = args.localImage
    def imageUri = args.imageUri
    def registry = args.registry
    def region = args.region

    echo "Pushing ${localImage} to ${imageUri}"

    sh """
        aws ecr get-login-password --region ${region} | \
        docker login --username AWS --password-stdin ${registry}

        docker tag ${localImage} ${imageUri}
        docker push ${imageUri}
    """
}