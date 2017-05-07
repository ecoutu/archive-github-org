# archive-github-org

Shell script for archiving a github user/org. 

## Running

This script depends on jq, curl and git:

```bash
sudo apt-get install -y jq curl git
```

Also, the aws command line tools for the uploading to s3 part (feel free to do what you wish with your archive, but 
configuring s3 is beyond the scope of this).

It accepts two positional arguments, github org and github token

eg invocation: 
  
```bash
./clone_org.sh <org> <gh_token>
```

## Disclaimer

This almost certainly would have been easier to write, read, and understand had it been written in a higher level 
language such as python.

### But... why?

If you are reading this then you know why. 

#### Ok, seriously

I needed something to backup / archive my personal projects that I keep stored on github. Once I started prodding at 
[github's super awesome api](https://developer.github.com/v3/) using simple tools such as curl I figured it would be 
fun to do a full implementation with said "unsophisticated" tools.

##### ...

Maybe you and I don't necessarily agree on what the meaning of "fun" is.