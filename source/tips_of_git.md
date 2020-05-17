# Gitの豆知識

## 01-01. トラブルシューティング

### 基点ブランチから二回派生するブランチマージする時の注意点

1. 基点ブランチから，一つ目のブランチにマージし，これをpushする．ここでpushしないと，2番目のブランチが一つ目のブランチとの差分を検出してしまい，大量の差分コミットがgithubに表示されてしまう．
2. 一つ目のブランチから二つ目のブランチにマージし．これをpushする．



### Conflictの解決方法とマージコミットの作成

1. ```git status```を行い，特定のファイルでのコンフリクトが表示される．

```bash
Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
        both modified:   XXX/YYY.twig
```

2. コンフリクトしていたコード行を取捨選択する．

```php
/// Phpstromにて，コンフリクトしていたコード行を取捨選択する．
```

3. 一度```add```を行い，コンフリクトの修正をGitに認識させる．

```bash
$ git add XXX/YYY.twig
```

4. ```git status```を行い，以下が表示される．コンフリクトが解決されたが，マージされていないと出力される．差分のファイルがたくさん表示される場合があるが，問題ない．

```bash
All conflicts fixed but you are still merging.

Changes to be committed:
        modified:   XXX
        modified:   XXX
```

5. ```git commit```（```-m```はつけてはいけない）を行い，vimエディタが表示される．

```bash
 Merge branch 'ブランチ名' into ブランチ名
```

7. ```:wq```でエディタを終了すれば，コンフリクトを解消したマージコミットが作成される．

8. ```git status```を行う．場合によっては，差分のコミット数が表示されるが問題ない．

```bash
Your branch is ahead of 'origin/feature/XXXX' by 10 commits.

```

9. pushする．この時，マージコミットを作成する時，基点ブランチ以外からマージしていると，差分のコミットが一つにまとまらず，

参考：http://www-creators.com/archives/1938



### Commitの粒度

データベースからフロント出力までに至る実装をCommitする場合，以下の3つを意識する．

1. データベースからCommit
2. 関連性のある実装をまとめてCommit
3. 一回のCommitがもつコード量が少なくなるようにCommit



### 誤って作成したプルリクの削除

不可能．
犯した罪は背負って生きていかなければならない．
参照：https://stackoverflow.com/questions/18318097/delete-a-closed-pull-request-from-github



## 01-02. Gitのコマンドメモ

### ```add```：

#### ・```add --all```

変更した全てのファイルをaddする．



### ```branch```：

#### ・```branch --all```
作業中のローカルブランチとリモート追跡ブランチを表示．

#### ・```branch --delete --force [ローカルブランチ名]```
プッシュとマージの状態に関係なく，ローカルブランチを削除．

#### ・```branch --move [新しいローカルブランチ名]```
作業中のローカルブランチの名前を変更．

#### ・```branch --delete --remote origin/[ローカルブランチ名]```
リモート追跡ブランチを削除．
（１）まず，```branch --all```で作業中のローカルブランチとリモート追跡ブランチを表示．

```
$ git branch --all
* master
  remotes/origin/2019/Symfony_Nyumon/master
  remotes/origin/master
```

（２）```remotes/origin/2019/Symfony_Nyumon/master```を削除．

```
$ git branch -d -r origin/2019/Symfony_Nyumon/master
Deleted remote-tracking branch origin/2019/Symfony_Nyumon/master (was 18a31b5).
```

（３）再び，```branch --all```で削除されたことを確認．

```
$ git branch --all
* master
  remotes/origin/master
```

#### ・```branch checkout -b [新しいローカルブランチ名] [コミット番号]```

```
git checkout -b feature/3 d7e49b04
```

指定のコミットから新しいブランチを生やすことができる．



### ```stash```：

ファイルが，『インデックス』（=```add```）あるいは『HEAD』（=```commit```）に存在している状態で，異なるローカルブランチを```checkout```しようとすると，以下のエラーが出る．

```
$ git checkout 2019/Symfony2_Nyumon/master
error: Your local changes to the following files would be overwritten by checkout:
        app/config/config.yml
        src/AppBundle/Entity/Inquiry.php
Please commit your changes or stash them before you switch branches.
Aborting
```

この場合，一度```stash```を行い，『インデックス』（=```add```）あるいは『HEAD』（=```commit```）を横に置いておく必要がある．

#### ・```stash -u```（```--include-untracked```）
トラッキングされていないファイルも含めて，全てのファイルを退避．
```git status```をしたところ，修正ファイルが３つ，トラックされていないファイルが１つある．

```
$ git status
On branch 2019/Symfony2_Nyumon/feature/6
Your branch is up to date with 'origin/2019/Symfony2_Nyumon/feature/6'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/Resources/views/Inquiry/index.html.twig
        modified:   app/config/config.yml
        modified:   src/AppBundle/Entity/Inquiry.php

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/Resources/views/Toppage/menu.html.twig

no changes added to commit (use "git add" and/or "git commit -a")
```

これを，```stash -u```する

```
$ git stash -u
Saved working directory and index state WIP on 2019/Symfony2_Nyumon/feature/6: 649995e update #6 xxx
```

これらのファイルの変更点を一時的に退避できる．

#### ・```stash -k ```（```save --keep-index```）→全てstashされてしまう

```add```していないファイルのみを```stash```することができる．

```bash
# stashしたくないファイルをaddする
git add example.php

# addされていない方のファイルをstashする．
git stash -k
```

#### ・```stash list```
退避している『ファイル番号：ブランチ：親コミットとコミットメッセージ』を一覧で表示．

```
$ git stash list
stash@{0}: WIP on 2019/Symfony2_Nyumon/feature/6: 649995e update #6 xxx
```

#### ・```stash pop stash@{番号}```
退避している指定のファイルを復元．

```
$ git stash pop stash@{0}
On branch 2019/Symfony2_Nyumon/feature/8
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/Resources/views/Inquiry/index.html.twig
        modified:   app/config/config.yml
        modified:   src/AppBundle/Entity/Inquiry.php

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/Resources/views/Toppage/menu.html.twig

no changes added to commit (use "git add" and/or "git commit -a")
```

#### ・```stash drop stash@{番号}```
退避している指定のファイルを復元せずに削除．

```
$ git stash drop stash@{0}
Dropped refs/stash@{0} (1d0ddeb9e52a737dcdbff7296272080e9ff71815)
```

#### ・```stash clear```
退避している全てのファイルを復元せずに削除．

```
$ git stash clear
```



### ```reset```：

作業中のローカルブランチにおいて，指定の履歴まで戻し，それ以降を削除．

![reset.png](https://qiita-image-store.s3.amazonaws.com/0/292201/e96468c4-57cc-bf2b-941a-d179ac829627.png)

#### ・```reset HEAD [ファイル名／ファイルパス]```
インデックスから，指定したファイルを削除．

#### ・```reset --soft [コミットID]```
作業中のローカルブランチにおいて，最新のHEAD（=```commit```後）を指定の履歴まで戻し，それ以降を削除
```commit```のみを取り消したい場合はこれ．

#### ・```reset --mixed [コミットID]```
作業中のローカルブランチにおいて，インデックス（=```add```後），HEAD（=```commit```後）を指定の履歴まで戻し，それ以降を削除．
```add```と```commit```を取り消したい場合はこれ．

#### ・```reset --hard [コミットID]```
作業中のローカルブランチにおいて，最新のワークツリー（=フォルダ），インデックス（=```add```後），HEAD（=```commit```後）を指定の履歴まで戻し，それ以降を削除．
<font color="red">**ワークツリー（=フォルダ）内のファイルの状態も戻ってしまうので，取り扱い注意！！**</font>

#### ・```reset```の使用例

（１）まず，```log ```で，作業中のローカルブランチにおけるコミットIDを確認．

```
$ git log
commit f17f68e287b7d84318b4c49e133b2d1819f6c3db (HEAD -> master, 2019/Symfony2_Nyumon/master)
Merge: 41cc21b f81c813
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 22:56:32 2019 +0900

    Merge remote-tracking branch 'refs/remotes/origin/master'

commit 41cc21bb53a8597270b5deae3259751df18bce81
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_2を追加

commit f81c813a1ead9a968c109671e6d83934debcab2e
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_1を追加
```

（２）指定のコミットまで履歴を戻す．

```
$ git reset --soft f81c813a1ead9a968c109671e6d83934debcab2e
```

（３）```log ```で，正しく変更されているか確認．

```
$ git log
commit f81c813a1ead9a968c109671e6d83934debcab2e (HEAD -> master)
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add 新しいREADMEを追加
```

（４）```push --force```でローカルリポジトリの変更をリモートリポジトリに強制的に反映．
<font color="red">**『強制的にpushした』というログも，リモート側には残らない．**</font>

```
$ git push --force
Total 0 (delta 0), reused 0 (delta 0)
To github.com:Hiroki-IT/Symfony2_Nyumon.git
 + f0d8b1a...f81c813 master -> master (forced update)
```

### ```rebase```：

作業中のローカルブランチにおいて，ブランチの派生元を変更．

#### ・```rebase --interactive [コミットID]```

派生元を変更する機能を応用して，過去のコミットのメッセージ変更，削除，統合などを行う．

- **コミットメッセージの変更**

（１）まず，```log ```で，作業中のローカルブランチにおけるコミットIDを確認．

```
$ git log
commit f17f68e287b7d84318b4c49e133b2d1819f6c3db (HEAD -> master, 2019/Symfony2_Nyumon/master)
Merge: 41cc21b f81c813
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 22:56:32 2019 +0900

    Merge remote-tracking branch 'refs/remotes/origin/master'

commit 41cc21bb53a8597270b5deae3259751df18bce81
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_2を追加

commit f81c813a1ead9a968c109671e6d83934debcab2e
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_1を追加
```

（２）指定した履歴の削除

```
$git rebase --interactive 41cc21bb53a8597270b5deae3259751df18bce81
```
とすると，タブが表示され，

```
pick b1b5c0f add #0 xxxxxxxxxx
```

指定のコミットIDの履歴が表示されるので，『挿入モード』に変更し，この一行の```pick```を```edit```に変更．その後，

```
:w
```

として保存．その後，エディタ上で『Ctrl+C』を押し，

```
:qa!
```

で終了．

（3）```commit --amend```でエディタを開き，メッセージを変更．

```
$ git commit --amend
```

（4）```rebase --continue```を実行．

```
$ git rebase --continue
Successfully rebased and updated refs/heads/develop.
```

（5）```push```しようとすると，```![rejected] develop -> develop (non-fast-forward)```とエラーが出るので，

```
git merge --allow-unrelated-histories
```
で解決し，```push```する．

#### ・```rebase --onto [派生元にしたいローカルブランチ名] [誤って派生元にしたローカルブランチ名] [派生元を変更したいローカルブランチ名]```

作業中のローカルブランチの派生元を変更．

```
$ git rebase --onto [派生元にしたいローカルブランチ名] [誤って派生元にしたローカルブランチ名] [派生元を変更したいローカルブランチ名]
```

#### ・```rebase --interactive --root```
一番古い，最初の履歴を削除．

（１）変更タブの表示

```
$ git rebase --interactive --root
```
とすると，最初の履歴が記述されたタブが表示される

```
pick b1b5c0f add #0 xxxxxxxxxx
```

（２）```pick b1b5c0f add #0 xxxxxxxxxx```の行を削除して保存し，タブを閉じ，エディタ上で『Ctrl+C』を押す．

```
:qa!
```

ここで未知のエラー

```
CONFLICT (modify/delete): README.md deleted in HEAD and modified in 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載
した. Version 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載した of README.md left in tree.
error: could not apply 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載した

Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".

Could not apply 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載した
```

#### ・```rebase --abort```

やりかけの```rebase```を取り消し．
作業中のローカルブランチにおける```(master|REBASE-i)```が，``` (master)```に変更されていることからも確認可能．

```
hasegawahiroki@Hiroki-Fujitsu MINGW64 /c/Projects/Symfony2_Nyumon
$ git rebase --interactive

hasegawahiroki@Hiroki-Fujitsu MINGW64 /c/Projects/Symfony2_Nyumon (master|REBASE-i)
$ git rebase --abort

hasegawahiroki@Hiroki-Fujitsu MINGW64 /c/Projects/Symfony2_Nyumon (master)
$
```



### ```revert```：

作業中のローカルブランチにおいて，指定の履歴を削除．

![revert.png](https://qiita-image-store.s3.amazonaws.com/0/292201/995d8f16-0a3e-117f-945f-c20a511edeaf.png)



### ```push ```

#### ・```push -u origin [作成したブランチ名]```

ローカルで作成したブランチを，リモートにpushする．コミットは無くても良い．

#### ・```push origin [コミットID]:master```：

トラウマコマンド



### ```show-branch```：

作業ブランチの派生元になっているブランチを確認．

```
git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -1 | awk -F'[]~^[]' '{print $2}'
```



## 02-01. GitHubにおけるIssueとPullReqの書き方

GitHubの個人的豆知識を以下に記す．

### Issueの作り方

一つのIssueとブランチにたくさんの実装をCommitすることは望ましくない．そこで，大きな対応を個々の対応に分割する．そして，大きな対応に関する基点Issueと基点ブランチを作成し，個々の対応に関連する子Issueと子ブランチを作成していく．個別の対応が終わったら，親ブランチへマージしていく．

**【Issueのテンプレート例】**

```markdown
## 対応内容
〇〇する

## 目的
〇〇の問題に対処するため．

## 参考画像
キャプチャ画像など．
```



### PullReqの作り方

実装途中のPullReqであり，実装方法などを質問したい場合に，タイトルに『WIP』とつけておく．レビューしてもらいたくなったら，これをはずす．レビュー修正時に，実装に時間がかかりそうであったら，再び付けても良い．

**【PullReqのテンプレート例】**

```markdown
## 対応内容
〇〇するように，以下を実装いたしました．

- あ
- い
- う

## 確認手順

## 参考画像

##　レビューしていただきたいところ
〇〇すると，△△となること．
```



### レビューの方法

#### ・実装の条件文や，コメントから，ビジネスルールや仕様を理解．

1. 条件文で```var_dump()``` を行う．
2. どういった入力がされた場合に，```true``` として判断しているのかを確認．例えば，受注済区分値が設定されているときに，それが失注区分値に変わった場合に，値を返却しているならば，そこから，『失注』のビジネスルールが垣間見える．
3. 定数に添えられたコメントから，仕様を理解．



#### ・```empty()``` ，```isset()``` などを正しく区別して使えているかを確認．

#### ・重複する処理を```foreach()```にまとめられないかを確認．

#### ・変数の格納が重複していないかを確認．