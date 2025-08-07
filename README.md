# gh-repo-archive

A shell script for archiving all repositories from a GitHub organization or user. The script clones all repositories, creates a compressed archive, and optionally uploads it to AWS S3.

## Prerequisites

This script depends on the following tools:

```bash
sudo apt-get install -y jq curl git
```

For S3 upload functionality, you'll also need the AWS CLI:

```bash
# Install AWS CLI (example for Ubuntu/Debian)
sudo apt-get install -y awscli
```

## Environment Variables

- `GITHUB_TOKEN`: Required GitHub personal access token with appropriate permissions to read organization or user repositories

## Usage

### Basic Usage

Clone and archive all repositories from an organization:

```bash
export GITHUB_TOKEN="your_github_token_here"
./gh-repo-archive -o <organization_name>
```

Clone and archive all repositories from a user:

```bash
export GITHUB_TOKEN="your_github_token_here"
./gh-repo-archive -u <username>
```

### With S3 Upload

Archive organization repositories and upload to S3:

```bash
export GITHUB_TOKEN="your_github_token_here"
./gh-repo-archive -o <organization_name> -b s3://your-bucket-name/path/
```

Archive user repositories and upload to S3:

```bash
export GITHUB_TOKEN="your_github_token_here"
./gh-repo-archive -u <username> -b s3://your-bucket-name/path/
```

### Command Line Options

- `-o, --organization`: GitHub organization name to archive (required if not using `-u`)
- `-u, --user`: GitHub user name to archive (required if not using `-o`)
- `-b, --bucket`: S3 bucket path for uploading the archive (optional)
- `-n, --name`: Custom archive filename (optional, defaults to `<org/user>-gh-archive-<timestamp>.tar.gz`)
- `-t, --tmp`: Custom temporary directory path (optional, defaults to `/tmp/<org/user>-gh-archive-<timestamp>`)

## How It Works

1. **Pre-flight checks**: Validates that required tools (jq, git, aws cli if needed) are installed
2. **Input validation**: Ensures organization name or user name and GitHub token are provided
3. **Fetches repository list**: Uses GitHub API to get all repositories from the specified organization or user
4. **Handles pagination**: Automatically follows pagination links to get all repositories
5. **Clones repositories**: Creates a local clone of each repository in a temporary directory
6. **Error handling**: Provides detailed error messages for different failure scenarios
7. **Creates archive**: Compresses all cloned repositories into a `.tar.gz` file
8. **Optional S3 upload**: Uploads the archive to the specified S3 bucket if provided
9. **Cleanup**: Removes temporary files and directories

## Output

The script creates an archive named `<organization/user>-gh-archive-<timestamp>.tar.gz` containing all cloned repositories.

## GitHub Token Permissions

Your GitHub token needs the following permissions:
- `repo` (if accessing private repositories)
- `read:org` (for organization repositories)
- `read:user` (for user repositories)

For public repositories only, a token with `public_repo` scope is sufficient.

## Examples

```bash
# Archive public repositories from 'myorg'
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
./gh-repo-archive -o myorg

# Archive public repositories from user 'myuser'
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
./gh-repo-archive -u myuser

# Archive organization and upload to S3
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
./gh-repo-archive -o myorg -b s3://my-backup-bucket/github-archives/

# Archive user repositories with custom name and temp directory
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
./gh-repo-archive -u myuser -n "my-custom-backup.tar.gz" -t "/home/user/temp"

# Make the script executable first
chmod +x gh-repo-archive
```

## Notes

- The script automatically checks for required dependencies (jq, git, aws cli) and exits with helpful error messages if they're missing
- Uses temporary directories under `/tmp/` by default, but can be customized with the `-t` option
- Archives are created in the current working directory by default, but filename can be customized with the `-n` option
- If S3 upload is configured, the script validates that AWS CLI is available before proceeding
- The script handles GitHub API pagination automatically to ensure all repositories are captured
- Progress is displayed with colored output showing start/success/failure status for each repository
- Provides specific error handling for common git clone issues:
  - Repository not found (404)
  - Repository already exists locally
  - Authentication failures
  - Other git-related errors with detailed messages

## Disclaimer

This almost certainly would have been easier to write, read, and understand had it been written in a higher level
language such as python.

### But... why?

While this could have been implemented more simply in a higher-level language, it was an enjoyable exercise in advanced shell scripting techniques and working with APIs using basic command-line tools.

#### Ok, seriously

I needed a way to backup and archive my personal projects hosted on GitHub. After exploring GitHub's excellent API using basic tools like curl, I decided it would be interesting to build a complete solution using these fundamental command-line utilities.

##### ...

Maybe you and I don't necessarily agree on what the meaning of "enjoyable" is.
