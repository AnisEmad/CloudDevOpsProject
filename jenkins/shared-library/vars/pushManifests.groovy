def call(Map args = [:]) {
    def repoUrl = args.repoUrl
    def branch = args.get('branch', 'main')
    def commitMessage = args.get('commitMessage', 'Update Kubernetes manifests')
    def credentialsId = args.get('credentialsId', 'github-pat')
    def paths = args.get('paths', 'kubernetes/')

    withEnv([
        "REPO_URL=${repoUrl}",
        "BRANCH=${branch}",
        "COMMIT_MESSAGE=${commitMessage}",
        "PATHS=${paths}"
    ]) {
        withCredentials([
            usernamePassword(
                credentialsId: credentialsId,
                usernameVariable: 'GIT_USER',
                passwordVariable: 'GIT_TOKEN'
            )
        ]) {
            sh '''
                set -e

                git config user.name "jenkins-ci"
                git config user.email "jenkins-ci@ivolve.local"

                AUTH_URL=$(echo "$REPO_URL" | sed "s|https://|https://${GIT_USER}:${GIT_TOKEN}@|")

                git remote set-url origin "$AUTH_URL"

                git add $PATHS

                if ! git diff --cached --quiet; then
                    git commit -m "$COMMIT_MESSAGE"
                    git push origin HEAD:$BRANCH
                else
                    echo "No manifest changes to commit"
                fi
            '''
        }
    }
}