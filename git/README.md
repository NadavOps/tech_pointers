# Git

### Table of Content
* [Git commands](#git-commands)
  * [Git config](#git-config)
  * [Git branch](#git-branch)
  * [Git diff](#git-diff)
  * [Git log show and blame](#git-log-show-and-blame)
  * [Git add](#git-add)
  * [Git push](#git-push)
  * [Git tag](#git-tag)
  * [Git rm](#git-rm)
  * [Git reset](#git-reset)
  * [Git revert](#git-revert)
  * [Git stash](#git-stash)
  * [Git remote](#git-remote)
  * [Git rebase](#git-rebase)
  * [Git cherry-pick](#git-cherry-pick)
  * [Git refs](#git-refs)
  * [Git plumbing tools](#git-plumbing-tools)

* [Multiple user configuration](#multiple-user-configuration)

* [Basic SSH config](#basic-ssh-config)

* [Examples](#examples)
  * [Changing history](#changing-history)
  * [Rebase master to feature branch](#rebase-master-to-feature-branch)
  * [Rebase upstream for PR](#rebase-upstream-for-pr)

* [Links](#links)

## Git commands

## Git config
```bash
# show configuration
git config --list

# set the user name and email
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "MY_NAME@example.com"

git config --local user.name "FIRST_NAME LAST_NAME"
git config --local user.email "MY_NAME@example.com"

# set git aliases
git config --global alias.co checkout
```

## Git status
```bash
# show untrackedfiles only
git status --porcelain --untracked-files=all
```

## Git branch
```bash
git branch
git branch -r                --> list branches at remote (--remote)
git branch -a                --> see all branches, seems like list remote branches
git branch -vv               --> shows branch refs
git branch -d <branch_name>  --> deletes a branch locally
git branch -D <branch_name>  --> deletes a branch
```

## Git diff
```bash
## git diff checks the difference between the working area and the staging area
## --cached checks the difference between the staging area and the current pointed commit
git diff
git diff --cached
git diff <unstaged_file>
git diff <branch_name> <branch_name2>
```

## Git log show and blame
```bash
git log --graph --decorate --oneline --> cleaner and add info :O
git log --patch --> see the changes in the commits
git log --grep <search_value> --> search for ceratin commits
git log -G<pattern> --> returns all the commits that were added or removed containing the pattern
git log HEAD~5..HEAD^ --> show a range of commits
git log feature_branch..main --online --> all the commits in "main" that are not in "feature_branch"

git blame <filename>

git show <commit_hash> --> details over a commit
git show HEAD^ --> details over the parent commit of HEAD
git show HEAD~3 --> details over the 3rd parent commit of head
git show HEAD~2^2 --> details over the 2nd commit of the 2nd parent commit of head (might be confusing or wrongly defined)
git show HEAD@{"1 month ago"} --> details over the parent commit of HEAD one month ago
```

## Git add
```bash
## interactive add for certain "hunks" in a file
git add --patch <filename>
```

## Git push
```bash
git push origin branch_name              -> Pushes a local branch to the origin remote. 
git push –u remote branch_name           -> there is semantics between this and the one above, not sure what yet 
git push -u origin master                -> push changes to origin from local master 
git push remote --delete branch_name     -> deletes a remote branch
```

## Git tag
```bash
git tag                                                --> lists the tags
git tag tag_name                                       --> simple tag which points stright to a commit.
git tag -a tag_name -m "msg"                           --> anotative tag which points to a tag object containing metadata which points to a commit.
git tag -d tag_name                                    --> deletes local tag
git push --delete origin tag_name                      --> delete remote tag
git push --delete origin $(git tag -l "some-pattern*") --> delete pattern tags from remote
git push origin tag_name                               --> push local tag to remote
git push origin --tags                                 --> push all local tags to remote
git fetch --prune --prune-tags                         --> delete remote refs that are no longer in use, tags and BRANCHES
```

## Git rm
```bash
## to remove a file from the staging area but maintain the content
git rm --cached
## to remove a file even if it was staged
git rm -f
```

## Git reset
```bash
# taken from https://stackoverflow.com/questions/2845731/how-to-uncommit-my-last-commit-in-git
# the ^ character means the commit before, in our case the commit before the HEAD (can use hash commit instead)
git reset --soft HEAD^           -> uncommit
git reset HEAD^                  -> Unstage
git reset --hard HEAD^           -> destroy work done
git reset --hard origin/main     -> destroy work done, will point to the remote HEAD
git checkout HEAD -- <file_name> -> destroys work done on a specific file (hard reset)

# taken from https://stackoverflow.com/questions/7099833/how-to-revert-a-merge-commit-thats-already-pushed-to-remote-branch
git checkout your_branch_name
git reset <commit-hash-before-the-bad-one>
git reset --hard
```

## Git revert
```bash
git revert <commit_hash> --> creats a new commit of the opposite changes that were dont in the referenced commit
```

## Git stash
```bash
## without untracked files
git stash
git stash --include-untracked
git stash list
git stash apply
git stash clear
```

## Git remote
```bash
git remote set-url origin new.git.url/here     --> set the remote origin URL
git remote add origin <GitHub repo link>       --> linking the initialized git working directory with the repo in GitHub
git remote set-url origin <GitHub repo link>   --> change the repo link
git remote rm origin                           --> remove the current link
git remote -v                                  --> lists the remotes
```

## Git rebase
```bash
git rebase -i <commit hash>                 --> interactive rebase
git rebase --onto <commit_hash> <ref_name>  --> rebase on a specific commit
```

## Git refs
```bash
# can help recover dangling commits that about to be garbaged collected
git show-ref <branch_name> --> Will show "branch names" of the remote and local and on what they are pointing
git reflog HEAD --> shows history of the HEAD pointer over the commits
git reflog refs/heads/master --> shows history of the master pointer over the commits
git ls-tree
git ls-remote
```

## Git cherry-pick
```bash
git cherry-pick <commit hash> -> will add a commit on top of the current HEAD
```

## Git plumbing tools
```bash
## "filter-repo" is the new command that will take over "filter-branch"
git filter-repo --path <filename> --> destroys all files but "filename" from all commits
git filter-repo --path <filename> --invert-paths --> destroys "filename" from all commits

## no really practical
cat filename | git hash-object --stdin --> generates a hash from text
git cat-file <commit_hash> -t --> the type behind the commit_hash
git cat-file <commit_hash> -p --> prints the value of the commit_hash
```

## Multiple user configuration
* Each config created with the following is representing a user with a specific SSH key, moreover it affects one directory recursively.
* The global configuration will be an include list for seperate configs each representing a user.
* With this configuration SSH config is not required.
```bash
# Inputs
git_username="enter_here"
git_email="enter_here@users.noreply.github.com"
git_ssh_key_name="private_key_file_name"
git_user_folder="repository_path"
git_config_suffix="$git_username"

# Generate SSH
ssh-keygen -t rsa -b 4096 -q -N "" -f "$HOME/.ssh/$git_ssh_key_name" -C "$git_ssh_key_name"

# Basic config
git config -f ~/.gitconfig.$git_config_suffix user.name "$git_username"
git config -f ~/.gitconfig.$git_config_suffix user.email "$git_email"
git config -f ~/.gitconfig.$git_config_suffix core.sshCommand "ssh -i $HOME/.ssh/$git_ssh_key_name"

# GPG sign config
git config -f ~/.gitconfig.$git_config_suffix user.signingkey $HOME/.ssh/$git_ssh_key_name.pub
git config -f ~/.gitconfig.$git_config_suffix gpg.format ssh
git config -f ~/.gitconfig.$git_config_suffix commit.gpgsign true
git config -f ~/.gitconfig.$git_config_suffix tag.gpgsign true

# Include the config in the main ~/.gitconfig file
git config --global "includeIf.gitdir:$git_user_folder/**.path" "~/.gitconfig.$git_config_suffix"

# Define the default config for the specific user, should be at the top of the global config $HOME/.gitconfig
git config --global "includeIf.gitdir:/**.path" "~/.gitconfig.$git_config_suffix"

# Run the following for global configuration -> stronger than the subconfigs
# git config --global user.name "$git_username"
# git config --global user.email "$git_email"
# git config --global user.signingkey "$HOME/.ssh/$git_ssh_key_name.pub"
# git config --global core.sshCommand "ssh -i $HOME/.ssh/$git_ssh_key_name"
# git config --global gpg.format ssh
# git config --global commit.gpgsign true
# git config --global tag.gpgsign true
```

## Basic SSH config
```bash
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/key_name
```

## Examples
## Changing history
```bash
git log; to find the desired commit
git rebase -i HEAD~3
git rebase -i <commit hash>
change the pick word (:%s/FindMe/ReplaceME/g)
    s to squash
    edit to overall change
        while in edit it is possible to run:
        git commit --amend --author="Author user_name <email_address_include_brackets>"

git commit --amend --> to change latest commit
```

## Rebase master to feature branch
```bash
# based on this https://www.verdantfox.com/blog/view/how-to-git-rebase-mainmaster-onto-your-feature-branch-even-with-merge-conflicts
# maybe should read this as well https://www.algolia.com/blog/engineering/master-git-rebase/
git checkout feature_branch  --> go to the feature branch
git fetch origin             --> syncs main branch with latest changes
git rebase origin/main       --> rebase the main branch, change to master if required
**fix conflicts and then
git add                      --> add file
git rebase --continue        --> continue with rebase
git rebase --skip            --> continue like this if git complains no changes were done after resolving conflict
git push                     --> push changes, force if needed
```

## Rebase upstream for PR
```bash
git remote -v
git remote add upstream ssh_or_https_URL
git fetch upstream master
git rebase upstream/master
git push -f / git push origin master --force
```


## Links
* [Set multiple ssh keys for multiple github accounts](https://gist.github.com/jexchan/2351996).
* [Changing history](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase).
* [Code academy git course](https://www.codecademy.com/learn/learn-git)
* [Github CLI](https://cli.github.com/manual/)
* [Set github profile as a social page](https://github.com/bobbyiliev/introduction-to-git-and-github-ebook/blob/main/ebook/en/content/997-create-your-github-profile.md)
* [Need to see how to sign commits and be verified](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
