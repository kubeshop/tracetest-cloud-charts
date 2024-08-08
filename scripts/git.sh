commit_and_push() {
    message=$1

    git config --global user.name "GitHub Actions"
    git config --global user.email ""

    git commit -m "$message"
    git push
}