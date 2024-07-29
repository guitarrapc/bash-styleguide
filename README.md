# bash-styleguide

スタイルガイドは絶対ではありません、必要なら壊してください。本スタイルガイドが目指すのは、Bashスクリプトを書く心理的障壁になるのを避けつつ、Bashスクリプトを書いていて悩んで答えがでない状況を減らすことです。Bashスクリプトは繊細でメンテナンスが難しく嫌いになりやすいことが多いでしょう。それでもBashスクリプトを書くことは必要なので、このスタイルガイドを用意しました。

迷ったときは、一貫性を最優先に決定してください。コードベース全体で1つのスタイルを一貫して使用することで、他の (より重要な) 問題に集中できます。一貫性があれば、自動化も可能になります。多くの場合、「一貫性を保つ」というルールは、「1つだけ選択して、それについて心配するのをやめる」ということになります。これらの点について柔軟性を許可する潜在的な価値は、人々がそれについて議論するコストを上回ります。ただし、一貫性には限界があります。一貫性は、明確な技術的議論や長期的な方向性がない場合に良い決着をつける要因となります。一方で、一貫性をもって、新しいスタイルの利点や、コードベースが古いスタイルのまま物事を進める正当化理由に用いられるべきではありません。

<!-- START doctoc -->
<!-- END doctoc -->

# はじめに (Introduction)

Bashスクリプトのスタイルガイドを示します。このスタイルガイドは、[Googleスタイルガイド (rev 2.03)](https://google.github.io/styleguide/shellguide.html)、[icy/bash-coding-style](https://github.com/icy/bash-coding-style)をベースに、一部独自規約で構成されています。意図的に独自規約にした項目は`(独自)`と明示しています。

用いる表示は次の通りです。

| 表記 | 意味 |
| --- | --- |
| ✔️ DO | 推奨します。 |
| ❌ DO NOT | 推奨しません。避ける努力をしてください。 |
| ⚠️ CONSIDER | 可能か検討してください。状況によっては適用することがあります。 |

## 自動化支援 (Automation Support)

スタイルガイドを守るにあたり、次の自動化が支援します。自動化支援によって注意されたことを守ることでスタイルガイドのほぼすべてが満たされます。(スクリプト構造は担保されません)

* PRで`shellcheck`の実行: ShellCheckのerrorがあった場合、CIで検出、注意を投げかけます
* インデントはEditorConfigで自動修正がかかります。VSCodeで[EditorConfig.EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)をインストールすることで、リアルタイムで適用されます
* VSCodeで[timonwong.shellcheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)をインストールすることで、リアルタイムでShellCheckの結果を確認できます
* ローカルでshellcheckを実行する手順を実行できます。次のコマンドを実行します

```shell
paths=(".")
for item in "${paths[@]}"; do
  for script in $(find "${item}" -type f -name "*.sh" | grep -v "/.git/"); do
    echo "## shellcheck: ${script}"
    shellcheck '--external-sources' "$script"
  done
done
```

## スタイルガイドでどう変わる (How the Style Guide Changes)

スタイルガイドに沿ったスクリプトは次の対応が標準的に入っていると期待できます。

* スクリプト構造が統一されます。スタイルガイドに示した通りの構造でスクリプト構造が一定になます
* shellcheckに対応します。shellcheckの標準実行で検出されるものはなく、一部過剰な警告はインラインで無視するためdisableされています
* CIによる`shellcheck`の自動実行が行われます。これにより`shellcheck`に違反した記述はPR時点で検出されます
* ローカルで`shellcheck`を実行する手順が明記されます。これによりCIでの警告をローカルで再現、先につぶすことができます
* 共通関数がサポートされ、`common::print`のようなログ関数やデバッグ有効化がサポートされます。これによりログフォーマットの統一、デバッグ機能の統一的な有効化が可能になります
* `--debug`引数がサポートされます。これによりスクリプトの変更なく`set -e`を有効にして実行できます
* `--dry-run`引数がサポートされます。作用のあるスクリプトで設定されており、処理を反映することなく何が実行されるか検証可能になります
* `--aws-args`引数がサポートされます。awsコマンドを含むスクリプトで引数が設定されており、ローカルの認証情報でスクリプトを実行できます
* 実行時にスクリプトの引数が表示されます。これにより処理開始前に何がどのような値で開始するか明確になります

自分が書くときは、スクリプトの構造に沿っていること、shellcheckの問題がないことを確認してください。この2点を満たすことでほとんどの些細なミスを防ぎ、一定のスクリプトデバッガビリティを確保できます。

* [スクリプトの構造 (Script Structure)](#スクリプトの構造-script-structure)にそってスクリプトを作成してください
  * --dry-runや--debugなどの共通引数を用意してください
  * 引数の初期化を行いましょう
  * 共通関数を用いたログ出力を行いましょう
  * 既存スクリプトをコピーするとやりやすいでしょう
* shellcheckの問題がローカル/PRで検出されないことを確認してください

# 背景 (Background)

## どのシェルを使うか (Which Shell to Use)

> **Note** 独自規約 (ベース: Googleスタイルガイド)

* ✔️ DO: すべてのスクリプトはBashを用います
* ✔️ DO: スクリプトの先頭に`#!/bin/bash`を記述します
* ✔️ DO: シェルオプション設定に`set -euo pipefail`を用います。(独自)
* ⚠️ CONSIDER: 他のシェルを使用する場合、その理由をコメントで記述します。(独自)

Bashを用いてください。実行可能ファイルは`#!/bin/bash`と最小限のフラグで始めます。全ての実行可能シェルスクリプトを`bash`に制限することで、全てのマシンにインストールされた一貫したシェルを使用できます。これに対する唯一の例外は、コーディング対象によって強制される場合です。例えば、Solaris SVR4パッケージはどんなスクリプトにもplain Bourne shellであることを要求するため`/bin/sh`を用います。

シェルオプションの設定に`set`を利用することで、スクリプトを`bash script_name`として呼び出してもその機能を損なわないようにします。`set -euo pipefail`は、スクリプトのエラーを早期に自動検出し、エラーが発生した場合にスクリプトを終了させるためのものです。`set -e`はエラーが発生した場合にスクリプトを終了させるためのものです。`set -u`は未定義の変数を参照した場合にエラーを発生させるためのものです。`set -o pipefail`はパイプラインの途中でエラーが発生した場合にスクリプトを終了させるためのものです。

**推奨 (recommended)**

```shell
#!/bin/bash
set -euo pipefail
```

**非推奨 (discouraged)**

```shell
#!/bin/bash
# setがありません
```

```shell
#!/bin/bash -euo pipefail
# setにしてください。bash ./function.sh としたとき-euoは無効になります。
```

## いつシェルを使うか (When to use Shell)

> **Note** 独自規約 (ベース: Googleスタイルガイド)

* ✔️ DO: 小さなユーティリティまたは単純なラッパー スクリプトにのみ使用してください
* ✔️ DO: GitHub ActionsなどCIで数行のスクリプトを書きたくなった場合、yamlファイルに埋め込むのではなくシェルスクリプトを作成してください。(独自)
* ✔️ DO: GitHub ActionsなどCIで複数のワークフローでパラメーター違いの同処理を呼び出す場合、yamlファイルに埋め込むのではなくシェルスクリプトを作成してください。(独自)
* ⚠️ CONSIDER: もしパフォーマンスが重要な場合、他言語を含めてシェル以外の手段を検討してください
* ⚠️ CONSIDER: 100行を超えるスクリプトや、単純ではない制御フロー ロジックを使用するスクリプトを書いている場合は、今すぐにより構造化された言語で書き直す必要があります。スクリプトは大きくなることを念頭に置いてください。後で時間のかかる書き直しを避けるために、早めにスクリプトを書き直してください
* ⚠️ CONSIDER: コードの複雑さを評価するときは (言語を切り替えるかどうかを決定する場合など)、コードの作成者以外の人がコードを簡単に保守できるかどうかを考慮してください

主に他のユーティリティを呼び出し、比較的少ないデータ操作しか行わない場合、シェルはタスクに適した選択肢です。シェルスクリプトは開発言語ではありませんが、CIでさまざまなユーティリティスクリプトの作成に使用されています。このスタイルガイドは、シェルスクリプトを広範囲に展開して使用することを提案するものではなく、シェルスクリプトの使用を認めるものです。

シェルスクリプトは小さな用途やシンプルなラッパースクリプトとして利用してください。特に、GitHub Actionsにおいて「複数行に渡る処理」や「複数のワークフローで再利用する処理」を書く場合にシェルスクリプトを用います。Bashはテキストを扱うことが容易な一方、あまりにも複雑な処理や言語/アプリ特有の処理を扱うケースでは向いていません。構造化してかける言語を検討するといいでしょう。

## シェルの実行環境 (Shell Execution Environment)

> **Note** 独自規約

* ✔️ DO: シェルの実行はGitHub Actionsの`ubuntu-latest`ランナーの実行を想定します
* ✔️ DO: ローカルで実行する場合、Ubuntu (WSL)を用います
* ⚠️ CONSIDER: 他の環境で実行する場合、その環境に合わせてシェルスクリプトを修正してください。(macOSなど)

シェルスクリプトはGitHub Actionsの`ubuntu-latest`ランナーの実行を想定しています。ローカルで実行する場合はUbuntu (WSL)を用います。
他環境ではGNU系コマンドである保証がないため、環境に合わせてシェルスクリプトを修正する必要があります。

# シェルファイルとインタプリタ呼出 (Shell Files and Interpreter Invocation)

## ファイル拡張子 (File Extensions)

> **Note** 独自規約 (ベース: Googleスタイルガイド)

* ✔️ DO: 外部から呼び出すスクリプトは`.sh`拡張子を用います
* ✔️ DO: 外部から呼び出さない内部専用のスクリプトには拡張子を用いません。(独自)

実行可能ファイルは「`.sh`(強く推奨)」か「拡張子なし」にします。外部から呼び出すスクリプトは必ず`.sh`とし実行可能にしません。

**推奨 (recommended)**

```shell
# 外部から呼び出すスクリプト
foo.sh

# 内部からしかよびださないスクリプト
_functions
```

**非推奨 (discouraged)**

```shell
# 外部から呼び出すスクリプトを拡張子なしにするのはやめましょう
foo

# 内部からしかよびださないスクリプトなのに.shをつけるのはやめましょう
functions.sh
```

## SUID/SGID

> **Note** 独自規約 (ベース: Googleスタイルガイド)

* ✔️ DO: 権限昇格が必要な場合`sudo`を使用してください
* ❌ DO NOT: SUIDやSGIDは禁止です
* ❌ DO NOT: GitHub Actionsのスクリプトは`sudo`も禁止です。(独自)

SUIDとSGIDはシェルスクリプトにおいて禁止です。シェルにはセキュリティの問題が多々あり、それによりSUID/SGIDを許可するのに十分な安全さを確保することはほぼ不可能です。bashはSUIDの実行を困難にするが、プラットフォームによってはそれが可能であるため明示的に禁止します。権限昇格が必要であれば`sudo`で呼び出してください。

GitHub Actionsで実行する限りにおいて、sudo、SUID、SGIDは使う必要がないため禁止します。

**推奨 (recommended)**

```shell
# 呼び出し時にsudoを使用
sudo foo.sh
```

**非推奨 (discouraged)**

```shell
# スクリプト内部でsuやrootユーザー切り替え
```

# 環境 (Environment)

## スクリプトの呼び出し (Script Invocation)

> **Note** 独自規約

* ✔️ DO: スクリプトの実行は、bashを経由して呼び出します
* ✔️ DO: スクリプト引数はクォートで囲みます。ただし固定文字列のようにスペースの入る余地がない場合はクォートを省略しても構いません
* ❌ DO NOT: スクリプトを直接実行してはいけません

スクリプトを直接実行することは避けてください。`bash`を経由して呼び出すことで、クリプトの実行環境を統一しスクリプトの実行環境を保証するとともに、exitによってインタラクティブに操作している現在のシェルが終了するのを防ぎます。

**推奨 (recommended)**

```shell
bash foo.sh

# スペースがない場合はクォートを省略しても構いません
bash foo.sh --baz true

# クォ－トで囲むことでスペースが入っても安全になる
bash foo.sh --foo "hello world" --bar "$bar"
```

**非推奨 (discouraged)**

```shell
# 直接呼出し
. ./foo.sh

# chmod +xで実行権限を与えて実行もだめ
chmod +x foo.sh
./foo.sh

# bar変数にスペースが含まれたり、空文字列だと引数解釈がおかしくなる可能性がある
bash foo.sh --foo hello world --bar $bar
```

## 共通関数スクリプト (Common Function Scripts)

> **Note** 独自規約

* ✔️ DO: 共通関数の呼び出しは`.`を用いてください

共通関数を呼び出す場合、`source`ではなく`.`用いてください。これは`.`がPOSIX準拠であるためです。ただ、shellcheck SC1091は避けるのが難しい場合もあるため、その時はshellcheck disableを用いてください。

**推奨 (recommended)**

```shell
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_functions"
```

**非推奨 (discouraged)**

```shell
# sourceではなく . を用いる
source "$(dirname "${BASH_SOURCE[0]}")/_functions"
```

## スクリプトの引数制御 (Script Argument Control)

> **Note** 独自規約

* ✔️ DO: 引数処理はwhile文で回しつつcase文で処理します
* ✔️ DO: スクリプトの引数は`--パラメーター名 値`のセットで受け取ります。パラメーター名は十分に理解できる名前を付けます
* ✔️ DO: スクリプトの引数指定が不要なオプショナル引数を用いる場合、ローカル変数で`${_変数名:=デフォルト値}`を使って初期化します
* ⚠️ CONSIDER: `--パラメーター名`単独で受け取ることは避けてください、ただし状況によっては許容され、この場合`shift 2`ではなく`shift`を用います
* ❌ DO NOT: スクリプトの引数はをパラメーター指定なしで`値1 値2 値3`のように受け取りません
* ❌ DO NOT: スクリプトの引数名に`--f`のような1文字の引数名や`--ns`のような省略名は避けてください

スクリプトの引数制御は引数をwhileでループさせながらcase文で判定、shiftで引数をずらしながら解析します。スクリプトの引数として受ける場合、ローカル変数や定数と区別するため変数は`_大文字`とします。スクリプトの引数は、処理本体へ入る前に初期化を確実に行い、ログ表示を行うことでデバッグを容易にします。

**推奨 (recommended)**

```bash
set -euo pipefail # -uによって初期化されていない変数で処理を止める

while [[ $# -gt 0 ]]; do
  case $1 in
    # required (省略不能な引数。指定しないと初期化で止める)
    --bar-piyo) _BAR_PIYO=$2; shift 2; ;; # `--bar-piyo "値"`で受け取る
    # optional (省略可能な引数。デフォルト値で初期化する)
    --optional) _OPTIONAL=$2; shift 2; ;; # 省略可能。変数の表示時にデフォルト値で初期化する
    *) shift ;;
  esac
done

# 変数を初期化する
common::print "引数:"
common::print "--bar-piyo=${_BAR_PIYO}" # オプショナルな引数は、省略されてもここでデフォルト値で初期化する
common::print "--optional=${_OPTIONAL:="true"}" # オプショナルな引数は、省略されてもここでデフォルト値で初期化する
```

**非推奨 (discouraged)**

```bash
set -euo pipefail # -uによって初期化されていない変数で処理を止める

while [[ $# -gt 0 ]]; do
  case $1 in
    # required
    -f) _FOO_=$2; shift 2; ;; # ハイフン一つの引数名はダメ
    --bar) _BAR=true; shift; ;; # 引数なしで受け取ることは可能なら避けてtrue/falseで受けるほうが望ましい
    # optional
    -o) _OPTIONAL=$2; shift 2; ;; # 変数初期化がないので引数に指定されないと実行時に落ちる
    *) shift ;;
  esac
done

# 変数初期化なし
```

## デバッグモードとドライランモード (Debug and Dry-run Mode)

> **Note** 独自規約

* ✔️ DO: `--debug true|false`のようなデバッグモードを用意します
* ✔️ DO: `--dry-run true|false`のようなドライランモードを実行不能な場合を除いて用意します
* ✔️ DO: `--dry-run`引数省略時のデフォルト値は`true`にします

スクリプトの共通の引数として`--debug`と`--dry-run`を入れることを検討してください。デバッグモードやドライランモードはスクリプトの動作を変更するため、デバッグやテストを行う際に有用です。デバッグモードは`set -x`を有効にすることでスクリプトの実行をトレースします。ドライランモードは実際のコマンドを実行せず、実行されるコマンドを表示したりコマンドのドライランモードを利用することで、スクリプトの動作を確認します。
デバッグモードやドライランを用意する初期化処理でスクリプト全体が長くなりがちですが、スクリプトの動作を変更するための引数は必要なものと割り切ります。

`--dry-run`引数省略時のデフォルト値は`true`にすることで、スクリプトを実行しても間違って実行されないようにします。これは不意の実行を防ぐためにとても有用です。

**推奨 (recommended)**

```bash
# ... 省略

# 引数処理
while [[ $# -gt 0 ]]; do
  case $1 in
    # optional
    --debug) _DEBUG=$2; shift 2; ;; # デバッグモード
    --dry-run) _DRYRUN=$2; shift 2; ;; # ドライランモード
    *) shift ;;
  esac
done

# 変数を初期化する
common::print "引数:"
common::print "--debug=${_DEBUG:="false"}" # デフォルトfalseにしてデバッグモードは必要な時だけ有効にします
common::print "--dry-run=${_DRYRUN:="true"}" # デフォルトtrueにしてスクリプトをただ実行しても間違って実行されないようにします

# デバッグモードを設定する
common::debug_mode # 共通スクリプトでset -xがかかります

# ドライランの用意
dryrun=""
dryrun_k8s=""
dryrun_aws=""
dryrun_az=""
if [[ "${_DRYRUN}" == "true" ]]; then
  dryrun="echo (dryrun) "
  dryrun_k8s="--dry-run=server"
  dryrun_aws="--dryrun"
  dryrun_az="--dryrun"
fi

# 共通関数を使ってデバッグメッセージを出力できる。common::debugの実装は次のようなものをイメージしてください
# function common::debug {
#   if [[ "${_DEBUG:=false}" == "true" ]]; then
#     echo "$*"
#   fi
# }
common::debug "デバッグメッセージ"

# コマンドをechoに置き換えることでドライランモードを実現
$dryrun dotnet run ...

# kubectlは--dry-run=serverを指定することでサーバーサイド検証付きでドライランモードを実現
kubectl apply -f ./manifests ${dryrun_k8s}

# aws s3 cpは--dryrunを差し込むことでドライランモードを実現
aws s3 cp $dryrun_aws ...

# aws s3以外はドライランモードがないことがほとんどなのでechoに差し替えが妥当
$dryrun aws scheduler ...

# az webappは--dryrunを差し込むことでドライランモードを実現
az webapp up $dryrun_az ...

# az containerappは--dryrunがないのでechoに差し替えが妥当
$dryrun az containerapp ...
```

**非推奨 (discouraged)**

```shell
# 強制で-xで入れるとスクリプト実行が読みづらいのでデバッグモードを用意しましょう
set -euxo pipefail

# 引数処理
while [[ $# -gt 0 ]]; do
  case $1 in
    # --debugは必須です。入れてね。
    # --dry-runできそうなのに入れないのはなぜ?
    *) shift ;;
  esac
done

# デバッグモードがないので標準出力される
echo "デバッグメッセージ"

# dry-runできそうじゃない!?
dotnet run ...

# dry-runできそうじゃない!?
kubectl apply -f ./manifests

# dry-runできそうじゃない!?
aws s3 cp ...

# dry-runできそうじゃない!?
az webapp up ...
```

## ローカルで実行可能にする (Make It Executable Locally)

> **Note** 独自規約

* ✔️ DO: スクリプトはローカル環境で実行可能にします
* ❌ DO NOT: 利用者にスクリプトで使っているCLIの知識を求めることは避けてください

スクリプトをローカル環境で実行可能にすることで、スクリプトの開発が用意になり、また動作を確認しやすくなります。スクリプトの実行を可能にするためには、AWS引数やドライランモードなどのオプションを提供することが有効です。一方で、`az login`のように事前にログインすることで以降のセッションで認証指定する必要がない場合は、この考慮は不要です。

**推奨 (recommended)**

```shell
# ローカル実行時に--aws-argsを指定することでAWS認証情報を渡す
$ my_script.sh --aws-args "--profile aws-profile --region ap-northeast-1" --dry-run true
```

```shell
# ... 省略

# 引数処理
while [[ $# -gt 0 ]]; do
  case $1 in
    # optional
    --aws-args) _AWS_ARGS=$2; shift 2; ;;
    *) shift ;;
  esac
done

# 変数を初期化する
common::print "引数:"
common::print "--aws-args=${_AWS_ARGS:=""}"

# ... 省略

# ローカル認証用の引数をスクリプト実行時に与えて実行できる
aws rds describe-db-clusters $_AWS_ARGS
```

**非推奨 (discouraged)**

```shell
# ローカル実行時に環境変数などを駆使してAWS認証情報を渡すことになる。実行者にaws cli知識が必要になる。
$ AWS_PROFILE=aws-profile AWS_REGION=ap-northeast-1 my_script.sh
```

```shell
# ... 省略

# awsコマンドをローカルで実行できるかは環境次第で、ユーザーを選んでしまう
aws rds describe-db-clusters
```


## STDOUT vs STDERR

> **Note** 独自規約 (ベース: Googleスタイルガイド)

* ✔️ DO: エラーメッセージはSTDERRに出力します
* ❌ DO NOT: エラーメッセージをSTDOUTに出力しないでください

エラーメッセージは`STDERR`に出力することで、通常の状態と本質的な問題の切り分けを容易にします。スクリプトで独自関数を定義するのではなく共通関数`common::error`関数を用いてください。

**推奨 (recommended)**

```shell
function common::error {
  echo "ERROR(${FUNCNAME[1]:-unknown}):: $*" >&2
}

if ! do_something; then
  common::error "Unable to do_something"
  exit 1
fi
```

**非推奨 (discouraged)**

```shell
if ! do_something; then
  echo "Unable to do_something"
  exit 1
fi
```

# 命名規則 (Naming Conventions)

## 関数名 (Function Names)

> **Note** 独自規約 (ベース: Googleスタイルガイドとicy/bash-coding-style)

* ✔️ DO: キーワード`function`を付けます。(独自)
* ✔️ DO: 小文字、単語の区切りにはアンダースコアを利用します
* ✔️ DO: 共通スクリプトはパッケージと関数名を`::`で区切ります
* ✔️ DO: 共通スクリプト内部でしか利用されなくない関数は`__`をプレフィックスにつけます。(独自)
* ❌ DO NOT: 関数名の後にカッコ`()`はつけません。(独自)

単一の関数を書いている場合、小文字と単語の区切りにはアンダースコアを利用してください。もし共通関数を書いている場合、関数名はパッケージ名と`::`で分離します。
ブレースは関数名と同じ行に記述します。関数名の後に`()`が存在する場合`function`キーワードは必須じゃありませんが、関数であることを明示するためにfunctionを用い`()`は利用しません。

**推奨 (recommended)**

```shell
# 単一の関数
function my_func {
  ...
}

# パッケージとして公開する関数
function mypackage::my_func {
  ...
}

# パッケージの内部でしか使ってほしくない関数は__をプレフィックスにつける
function __super_internal_func {
  ...
}

```

**非推奨 (discouraged)**

```shell
# functionがなく()が利用されている
MyFunc () {
  ...
}

# 関数名がパスカルケース
function MyFunc {
  ...
}

# 関数名がキャメルケース
function myFunc  {
  ...
}

# パッケージと関数名の区切り::がない
function package_my_func {
  ...
}
```

## 変数名 (Variable Names)

> **Note** 独自規約 (ベース: Googleスタイルガイドとicy/bash-coding-style)

* ✔️ DO: 関数名と同様に小文字、単語の区切りにはアンダースコアを利用します
* ✔️ DO: ループの変数名は、ループ対象の変数と似た名前にします

**推奨 (recommended)**

```shell
for zone in "${zones[@]}"; do
  something_with "${zone}"
done
```

**非推奨 (discouraged)**

```shell
for item in "${zones[@]}"; do
  something_with "${item}"
done
```

定数と環境変数は大文字で宣言します。定数はファイルの先頭で宣言します。

* ✔️ DO: 定数は全て大文字、区切りはアンダースコア、ファイルの先頭で宣言します
* ✔️ DO: 定数とエクスポートされる環境変数は大文字で宣言します

**推奨 (recommended)**

```shell
# 定数
readonly PATH_TO_FILES='/some/path'

# 定数と環境変数
declare -xr ORACLE_SID='PROD'
```

**非推奨 (discouraged)**

```shell
# 定数を小文字宣言
readonly path_to_file='/some/path'

# 定数と環境変数を小文字宣言
declare -xr oracle_sid='PROD'
```

スクリプトの引数処理のように親スコープとなるユーザー実行から与えられる変数は`_大文字`、区切りはアンダースコアで宣言します。

グローバル変数はシェル全体で使用されるため、それらの利用時にエラーを捕捉することが重要です。読み取り専用を意図した変数をの宣言を明示的に行います。

* ⚠️ CONSIDER: `readonly`や`declare -r`を使って読み取り専用を保証します。このスタイルは可能であれば実施しますが無理に行う必要はありません。(独自)

**推奨 (recommended)**

```shell
readonly zlib1g_version="$(dpkg --status zlib1g | grep Version: | cut -d ' ' -f 2)"
if [[ -z "${zlib1g_version}" ]]; then
  echo "error message"
fi
```

**非推奨 (discouraged)**

```shell
# 読み取り専用になっていない
zlib1g_version="$(dpkg --status zlib1g | grep Version: | cut -d ' ' -f 2)"
if [[ -z "${zlib1g_version}" ]]; then
  error_message
fi
```

関数内で`local`を使って変数宣言すると変数が関数とその子の内側のみから見えることを保証できます。代入値にコマンド置換を用いる場合、宣言と代入は異なる文で行ってください。これはコマンドの終了コードが`local`で上書きされて伝播しないためです。

* ✔️ DO: 関数専用の変数は`local`で宣言します
* ✔️ DO: `local`によって代入の終了コードが上書きされるのを避けるため、値の代入にコマンド置換を用いる場合は宣言と代入は異なる行で行います

**推奨 (recommended)**

```shell
my_func2() {
  # エラーが出得ない代入ならば宣言と代入は同じ行で行ってもよい
  local name="$1"

  # コマンド置換で代入する場合、宣言と代入の行は分離
  local my_var
  my_var="$(my_func)"
  (( $? == 0 )) || return

  ...
}
```

**非推奨 (discouraged)**

```shell
my_func2() {
  # $? は常にゼロになっていしまう。なぜならmy_func ではなく、'local' の終了コードを保持するため
  local my_var="$(my_func)"
  (( $? == 0 )) || return

  ...
}
```

# コメント (Comments)

## ファイルヘッダー (File Header)

> **Note** Googleスタイルガイド

* ✔️ DO: ファイルの先頭にはファイルの目的や内容を簡潔に説明するコメントを記述します。ただしshebang行の前にはコメントを記述しません

ファイルは内容の説明の記述から始めます。全てのファイルに内容の簡単な説明を含むtop-level commentが記述します。

**推奨 (recommended)**

```bash
#!/bin/bash
#
# Perform hot backups of Oracle databases.
```

## コメントの実装 (Implementation Comments)

> **Note** Googleスタイルガイド

* ✔️ DO: トリッキーだったり重要な意味をもつなど注意を要するコードにはコメントを付与します
* ✔️ DO: コメントは可能なら短く、理解しやすい説明をします
* ⚠️ CONSIDER: 端的に説明できない場合、背景を含めて詳細に説明することも検討してください

トリッキーであったり、一目瞭然でない、興味深い、もしくは重要なコードの部分にコメントします。ただし全てにはコメントしてはいけません。複雑なアルゴリズムが存在したり、通常から外れたことをしている場合に、可能ならコメントを付与します。短いコメントで理解しやすい説明ができない場合、背景を含めて詳細に説明します。

## TODO コメント (TODO Comments)

> **Note** 独自規約 (ベース: Googleスタイルガイド)

* ✔️ DO: TODOコメントの利用を検討してください
* ❌ DO NOT: TODOコメントを記述した個人をコメントに明記しないでください。(独自)

一時的であったり、短期的な解決策、概ね良いが完璧でないコードにはTODOコメントを利用します。`TODO`には全て大文字の文字列`TODO`を含めます。誰が書いたかは`git brame`で確認できるため、個人識別名を書く必要はありません。TODOコメントの目的は、要求に応じてより詳細を探すために、検索可能な一貫した`TODO`を用意することです。`TODO`は参照された人物が問題を修正する確約ではないので、想定する修正を付記すると後々修正しやすいでしょう。

**例**

```bash
# TODO: このコードはエラー処理が不足しているため修正が必要です。エラー判定を追加してexit 1で終了させます。
```

# フォーマット (Formatting)

既存のファイルを編集しているときはそのスタイルに従う必要があるが、新しいコードには次のスタイルを適用します。

## タブとスペース (Tabs and Spaces)

> **Note** 独自規約 (ベース: Googleスタイルガイドとicy/bash-coding-style)

* ✔️ DO: EditorConfigに従って自動整形します。(独自)
* ✔️ DO: 2つのスペースでインデントします。タブは用いません
* ✔️ DO: 可読性向上のため、ブロック間には空行を入れます
* ✔️ DO: 末尾スペースは入れません。(独自)
* ✔️ DO: ファイルの末尾には改行を入れます。(独自)
* ❌ DO NOT: 既存ファイルに無理にスタイルを適用しないでください。既存ファイルはそのファイルのスタイルを守ってください

EdiroConfigでインデントや末尾スペース、ファイル末尾の改行が自動修正されます。インデントは2つのスペースです。何をするにしても、タブは利用不可です。

多くのエディターは実際のインデントと、表示錠のスペース/タブを好みに応じて切替することは出来ません。別の人のエディターはあなたのエディターと同じ設定を持っているとは限りません。スペースを使うことで、コードがどのエディターでも同じように見えることを保証します。

既存のファイルでは、既存のインデントを忠実に守ってください。既存ファイルに無理にスタイルを適用する必要はありませんが、EditorConfigによる自動修正がかかった場合、それはコミットをしてください。

## 行の長さと長い文字列 (Line Length and Long Strings)

> **Note** 独自規約

* ✔️ DO: 長すぎる文字列の記述にはヒアドキュメントや埋め込み改行を検討してください
* ⚠️ CONSIDER: 文字列リテラルの長さを短くする方法を探してください

行の最大の長さはなく、N文字で改行する規約はありません。ただし、あまりに長い文字列を記述する必要がある場合、可能であればヒアドキュメントや埋め込み改行を検討してください。適切に分割できない文字列リテラルの存在は許容されますが、短くする方法を探すことを強く推奨します。

**推奨 (recommended)**

```shell
# ヒアドキュメントの利用
cat <<END
I am an exceptionally long
string.
END

# 埋め込み改行
long_string="I am an exceptionally
long string."

# 配列の改行
array=(
  "foo"
  "bar"
  "baz"
)
```

**非推奨 (discouraged)**

```shell
# 1行に\nを用いて納める。(Slack APIなど事情がある場合はOK)
str="I am an exceptionally long\nstring."

# 配列にならべすぎる
array=("foo" "bar" "baz" "piyo" "okonomi" "oosugiiiiii")
```

## パイプライン (Pipelines)

> **Note** 独自規約 (ベース: Googleスタイルガイドとicy/bash-coding-style)

* ✔️ DO: パイプライン全体がすっと1行に収まるなら1行で記述します
* ✔️ DO: パイプライン全体が長く読みにくい場合、1行ごとに分割します
* ✔️ DO: `|`によるコマンドの連鎖や、`||`や`&&`の論理演算子による連結も同様

パイプラインは全体が長く読みにくい場合、1行ごとに分割します。もしパイプライン全体がすっと1行に収まるなら1行で記述します。
改行する場合、後続するパイプセクションのために改行し継続を示す`\`を末尾に付与、2つのスペースでインデントし、パイプを置く形式でパイプセグメントが行ごとに分割します。パイプを末尾において改行しないでください。
これは`|`によるコマンドの連鎖や、`||`や`&&`の論理演算子による連結にも適用されます。

**推奨 (recommended)**

```bash
# 1行に全て収まる場合
command1 | command2

# 長いコマンド
command1 \
  | command2 \
  | command3 \
  | command4
```

**非推奨 (discouraged)**

```bash
# 1行に全て収まるのに改行は不要
command1 \
  | command2

# 長いコマンドで改行を用いないのは読むのが困難
command1 | command2 | command3 | command4
```

## ループ (Loops)

> **Note** Googleスタイルガイド

* ✔️ DO: `; do`と`; then`は、`while`, `for`そして`if`と同じ行に置きます
* ✔️ DO: `elif`や`else`は独自の行に置きます

シェルのループは少し変わっていますが、関数の宣言時におけるカッコの原則に従い`; then`と`; do`はif/for/whileと同じ行に置きます。`else`は独自の行に置かれるべきであり、閉じ構文も独自の行に置かれるべきです。そしてそれらは開き構文に垂直方向で整列されるべきです。

**推奨 (recommended)**

```shell
if [[ nantoka ]]; then
  ;;
fi

for i in $(seq 1 10); do
  echo $i
done
```

**非推奨 (discouraged)**

```shell
if [[ nantoka ]];
then
  ;;
fi

for i in $(seq 1 10)
do
  echo $i
done
```

## case文 (Case statement)

> **Note** Googleスタイルガイド

* ✔️ DO: 候補は2つのスペースでインデントします
* ✔️ DO: 1行の候補では、パターンの閉じカッコの後ろ、及び`;;`の前に、1つのスペースが必要です
* ✔️ DO: 長いもしくは複数コマンドの候補は、パターン、アクション、そして`;;`が複数行に分割します
* ⚠️ CONSIDER: 短いコマンドの候補は、パターン、アクション、そして`;;`を1行に収めることも検討してください

条件式は`case`や`esac`から1レベルインデントします。複数行のアクションはさらなるレベルにインデントします。パターン表現の前に開きカッコがあってはならない。`;&`や`;;&`の記法は回避します。

**推奨 (recommended)**

```shell
case "${expression}" in
  "--a")
    _VARIABLE_="..."
    ;;
  "--absolute")
    _ACTIONS="relative"
    ;;
  *) shift ;;
esac
```

単純なコマンドは式の可読性が保たれるならば、パターンおよび`;;`と同じ行に配置します。アクションが単一行に収まらない場合、パターンは独自の行に置き、次にアクション、次に`;;`を同様に独自の行に置きます。パターンをアクションと同じ行に配置する場合、パターンの閉じカッコの後ろ、及び`;;`の前に、1つのスペースを入れます。

## 変数展開 (Variable expansion)

> **Note** Googleスタイルガイド

* ✔️ DO: 一貫した変数展開します
* ✔️ DO: 変数展開はダブルクォートで囲みます。シングルクォートでは変数展開されません
* ❌ DO NOT: 明示的に必要な場合もしくは深刻な混乱を避ける場合を除いて、シェル特殊変数/位置パラメータはブレースで区切るな

変数はクォートします。`$var`よりもブレースで囲んだ`${var}`を用います。
強く推奨されるガイドラインですが、必須のレギュレーションではありません。ただし必須ではないものの、これを軽視しないでください。

その他全ての変数はブレースで区切るのが好ましい。

**推奨 (recommended)**

```shell
# Preferred style for 'special' variables:
echo "Positional: $1" "$5" "$3"
echo "Specials: !=$!, -=$-, _=$_. ?=$?, #=$# *=$* @=$@ \$=$$ …"

# Braces necessary:
echo "many parameters: ${10}"

# Braces avoiding confusion:
# Output is "a0b0c0"
set -- a b c
echo "${1}0${2}0${3}0"

# Preferred style for other variables:
echo "PATH=${PATH}, PWD=${PWD}, mine=${some_var}"
while read -r f; do
  echo "file=${f}"
done < <(find /tmp)
```

**非推奨 (discouraged)**

```shell
# Unquoted vars, unbraced vars, brace-delimited single letter
# shell specials.
echo a=$avar "b=$bvar" "PID=${$}" "${1}"

# Confusing use: this is expanded as "${1}0${2}0${3}0",
# not "${10}${20}${30}
set -- a b c
echo "$10$20$30"
```

## クォート (Quoting)

> **Note** Googleスタイルガイド

* ✔️ DO: クォートされていない展開が要求される場合や、シェル内部整数である場合を除き、変数、コマンド置換、スペースやシェルのメタ文字を含む文字列は常にクォートします
* ✔️ DO: 複数の要素を安全にクォートするために配列を利用します。特にコマンドラインフラグの場合。後述の[配列 (Arrays)](#配列-arrays)参照
* ✔️ DO: 整数として定義されるシェル内部の読み取り専用特殊変数のクォートはオプションです: `$?`, `$#`, `$$`, `$!` (`man bash`参照)。一貫性のため、"${PPID}"のように整数な内部変数はクォートします
* ✔️ DO: 文字列変数`"${words}"`はクォートします
* ❌ DO NOT: 整数リテラルはクォートしてはいけません。`$((2 + 2))`のような数値演算はクォートしてはいけません
* ⚠️ CONSIDER: `[[...]]`中のパターンマッチにおけるクォートの規則に注意を払え。後述の[Test](#test)参照
* ⚠️ CONSIDER: 単純に引数をメッセージの文字列やログに追記するような特別な理由でないならば、`$*`ではなく`"$@"`を利用します

```shell
# 'Single' quotes indicate that no substitution is desired.
# "Double" quotes indicate that substitution is required/tolerated.

# Simple examples

# "quote command substitutions"
# Note that quotes nested inside "$()" don't need escaping.
flag="$(some_command and its args "$@" 'quoted separately')"

# "quote variables"
echo "${flag}"

# Use arrays with quoted expansion for lists.
declare -a FLAGS
FLAGS=( --foo --bar='baz' )
readonly FLAGS
mybinary "${FLAGS[@]}"

# It's ok to not quote internal integer variables.
if (( $# > 3 )); then
  echo "ppid=${PPID}"
fi

# "never quote literal integers"
value=32
# "quote command substitutions", even when you expect integers
number="$(generate_number)"

# "prefer quoting words", not compulsory
readonly USE_INTEGER='true'

# "quote shell meta characters"
echo 'Hello stranger, and well met. Earn lots of $$$'
echo "Process $$: Done making \$\$\$."

# "command options or path names"
# ($1 is assumed to contain a value here)
grep -li Hugo /dev/null "$1"

# Less simple examples
# "quote variables, unless proven false": ccs might be empty
git send-email --to "${reviewers}" ${ccs:+"--cc" "${ccs}"}

# Positional parameter precautions: $1 might be unset
# Single quotes leave regex as-is.
grep -cP '([Ss]pecial|\|?characters*)$' ${1:+"$1"}

# For passing on arguments,
# "$@" is right almost every time, and
# $* is wrong almost every time:
#
# * $* and $@ will split on spaces, clobbering up arguments
#   that contain spaces and dropping empty strings;
# * "$@" will retain arguments as-is, so no args
#   provided will result in no args being passed on;
#   This is in most cases what you want to use for passing
#   on arguments.
# * "$*" expands to one argument, with all args joined
#   by (usually) spaces,
#   so no args provided will result in one empty string
#   being passed on.
#
# Consult
# https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html and
# https://mywiki.wooledge.org/BashGuide/Arrays for more

(set -- 1 "2 two" "3 three tres"; echo $#; set -- "$*"; echo "$#, $@")
(set -- 1 "2 two" "3 three tres"; echo $#; set -- "$@"; echo "$#, $@")
```

## 関数の宣言 (Function Declaration)

> **Note** Googleスタイルガイド

* ❌ DO NOT: 関数と関数の間に実行可能なコードを書くことを避けてください

関数宣言と関数宣言の間に処理を書くとコードの追跡が困難になり、結果デバッグ時に予期せぬ不幸を引き起こします。関数宣言は定数記述部分の直後に配置してください。

**推奨 (recommended)**

```shell
function foo() {
  ...
}
function bar() {
  ...
}

echo "何か処理"
```

**非推奨 (discouraged)**

```shell
function foo() {
  ...
}

echo "何か処理"

function bar() {
  ...
}
```

# 機能とバグ (Features and Bugs)

## ShellCheckを使う (Use ShellCheck)

> **Note** 独自規約 (ベース: Googleスタイルガイド)

* ✔️ DO: ShellCheckを使用してシェルスクリプトのバグを特定します
* ✔️ DO: ShellCheckの--severityレベルwarning以上をすべて解消させます。(独自)
* ⚠️ CONSIDER: ShellCheckの--severityレベルinfo以上をすべて解消することを検討します。(独自)
* ⚠️ CONSIDER: ShellCheckの--severityレベルinfoで解消できない場合`# shellcheck disable=SCXXXX`コメントを付与してignoreを検討します。(独自)

[ShellCheck](https://www.shellcheck.net/)プロジェクトはシェルスクリプトについての一般的なバグや警告を検出します。シェルスクリプトが大きかろうと小さかろうと全てに適用します。

shellcheckはWindows/Ubuntu/macOS各種で[インストール](https://github.com/koalaman/shellcheck)できます。

```shell
# Debian/Ubuntu
sudo apt install shellcheck
# macOS
brew install shellcheck
# Windows
winget install --id koalaman.shellcheck
scoop install shellcheck
```

**推奨 (recommended)**

```bash
# 部分式には$()を用います。
foo=$(cmd ...)

# パスのように空白入る可能性がある変数はクォートで囲みます。
ls "/foo/bar/${nanika_file}"

# sourceのパスが解消できないためSC1091の警告無視が必須なので許容される
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_functions"

# ドライラン用の$_AWS_ARGSを${_AWS_ARGS}にしないことでSC2086がでない。これが許容されるのは、空文字になる可能性、スペース区切りの複数引数になる可能性の両方あるためクォートで囲むことができない
aws s3 ls foo_bucket $_AWS_ARGS

# ドライラン用の$dryrunを${dryrun}にしないことでSC2086がでない。これが許容されるのは、空文字になる可能性、スペース区切りの複数引数になる可能性の両方あるためクォートで囲むことができない
$dryrun aws s3 ls foo_bucket $_AWS_ARGS
```

**非推奨 (discouraged)**

```bash
# SC2006として検出。部分式に``はスタイルガイド、shellcheck両方で禁止です、修正しましょう。
foo=`cmd ...`

# SC2086として検出。パスのように空白入る可能性がある変数はクォートで囲まないと警告が出ます。修正しましょう。
ls /foo/bar/${nanika_file}
```

## コマンド置換 (Command Substitution)

> **Note** Googleスタイルガイド

* ✔️ DO: backtick \`\` ではなく`$(command)`を使用します

入れ子になった内側のbacktickは`\`によるエスケープが求められますが、`$(command)`の形式なら入れ子になっても変更の必要がなく読みやすさを維持できます。

**推奨 (recommended)**

```shell
var=$(command "$(command1)")
```

**非推奨 (discouraged)**

```shell
var=`command \`command1\``
```

## Test構文 (Test Expression)

> **Note** Googleスタイルガイド

* ✔️ DO: `[ ... ]`ではなく`[[ ... ]]`を使用します

`[[ ... ]]`は`[ ... ]`, `test`そして`/usr/bin/[`よりも適切です。`[[ ... ]]`は`[[`と`]]`の間でパス名の展開や単語の分割が行われないためエラーを削減します。また、`[[ ... ]]]`は`[...]`とは違い、正規表現マッチングが可能です。

`[]`が引き起こす問題の背景は[詳細ページ](http://tiswww.case.edu/php/chet/bash/FAQ)のE14参照。

**推奨 (recommended)**

```shell
# This ensures the string on the left is made up of characters in
# the alnum character class followed by the string name.
# Note that the RHS should not be quoted here.
if [[ "filename" =~ ^[[:alnum:]]+name ]]; then
  echo "Match"
fi

# This matches the exact pattern "f*" (Does not match in this case)
if [[ "filename" == "f*" ]]; then
  echo "Match"
fi
```

**非推奨 (discouraged)**

```shell
# This gives a "too many arguments" error as f* is expanded to the
# contents of the current directory. It might also trigger the
# "unexpected operator" error because `[` does not support `==`, only `=`.
if [ "filename" == f* ]; then
  echo "Match"
fi
```

## 文字列のテスト (Testing Strings)

> **Note** Googleスタイルガイド

* ✔️ DO: 文字列の比較には`==`を使用します
* ✔️ DO: 数値比較する場合は`(( ... ))`または`-lt`や`-gt`を利用します
* ⚠️ CONSIDER: 空文字列の比較には`== ""`ではなく`-z`の使用を検討します
* ⚠️ CONSIDER: 文字列の比較において、固定文字列をプレフィックス/サフィックスにつけて文字列全体の比較をすることは避けましょう
* ⚠️ CONSIDER: 文字列の比較において、`<`や`>`は辞書的比較するため注意が必要です
* ❌ DO NOT: 文字列の比較には`=`を使用しません
* ❌ DO NOT: 数値の比較に`>`や`<`を使用しません

bashはtestで空文字列を十分スマートに扱えます。コードの可読性を考えて、文字列判定を用いてください。比較時に固定文字をプレフィックス/サフィックスにつけて文字列全体の比較をすることは避けましょう。

**推奨 (recommended)**

```shell
# Comparing strings
if [[ "${my_var}" == "some_string" ]]; then
  do_something
fi

# -z (string length is zero) and -n (string length is not zero) are
# preferred over testing for an empty string
if [[ -z "${my_var}" ]]; then
  do_something
fi

# This is OK (ensure quotes on the empty side), but not preferred:
if [[ "${my_var}" == "" ]]; then
  do_something
fi
```

**非推奨 (discouraged)**

```shell
# Avoid compare the whole string with a additional string
if [[ "${my_var}X" == "some_stringX" ]]; then
  do_something
fi
```

何をテストしているかの混乱を避けるため、明示的に`-z`や`-n`を利用します。

**推奨 (recommended)**

```shell
if [[ -n "${my_var}" ]]; then
  do_something
fi
```

**非推奨 (discouraged)**

```shell
if [[ "${my_var}" ]]; then
  do_something
fi
```

同値判定には`==`を利用し`=`は利用しません。前者は`[[`の利用を強制し、後者は代入と紛らわしくなります。ただし、`[[ ... ]]`の中での`<`と`>`は辞書的比較するため注意が必要です。数値比較する場合は`(( ... ))`または`-lt`や`-gt`を利用します。

**推奨 (recommended)**

```shell
# == を用いる
if [[ "${my_var}" == "val" ]]; then
  do_something
fi

# (())を用いる
if (( my_var > 3 )); then
  do_something
fi

# 数値比較は-gtや-ltが適切
if [[ "${my_var}" -gt 3 ]]; then
  do_something
fi
```

**非推奨 (discouraged)**

```shell
# = は使わない
if [[ "${my_var}" = "val" ]]; then
  do_something
fi

# 恐らく意図しない辞書的比較
if [[ "${my_var}" > 3 ]]; then
  # 4ならば真、22ならば偽
  do_something
fi
```

## ファイル名のワイルドカード展開 (Wildcard Expansion of Filenames)

> **Note** Googleスタイルガイド

* ✔️ DO: ファイル名のワイルドカード展開する場合は明示的なパス指定を行います
* ❌ DO NOT: ファイル名のワイルドカード展開する場合は`*`を使用しないでください。代わりに`./*`を使用します

ファイル名は`-`から始まる可能性があるため、ワイルドカード展開は`*`ではなく`./*`の方がより安全です。

```bash
# Here's the contents of the directory:
# -f  -r  somedir  somefile
```

**推奨 (recommended)**

```shell
# Prevent the accidental removal of files starting with `-`
$ rm -v ./*
removed `./-f'
removed `./-r'
rm: cannot remove `./somedir': Is a directory
removed `./somefile'
```

**非推奨 (discouraged)**

```shell
# Incorrectly deletes almost everything in the directory by force
$ rm -v *
removed directory: `somedir'
removed `somefile'
```

## Evalの禁止 (Eval is Evil)

> **Note** Googleスタイルガイド

* ❌ DO NOT: `eval`は使わないでください

`eval`は変数への代入に利用される場合、入力コードを難読化し、それらの変数が何であるかの確認を可能にすることなく変数を設定できます。`eval`はセキュリティリスクを伴うため、避けるべきです。

**非推奨 (discouraged)**

```shell
# What does this set?
# Did it succeed? In part or whole?
eval $(set_my_variables)

# What happens if one of the returned values has a space in it?
variable="$(eval some_function)"
```

## 配列 (Arrays)

> **Note** Googleスタイルガイド

* ✔️ DO: 配列を利用して複数の要素を格納します
* ✔️ DO: 改行で区切られた文字列出力は素直にループを利用することを検討してください。配列に変換するよりも簡単です
* ❌ DO NOT: 単一文字列に複数の要素を格納、連携することは避けます

bashの配列は、クォートの複雑さを回避して要素のリストを保存するのに使います。配列はより複雑なデータ構造の利用を容易にするため利用されるべきではありません。(前述の[いつシェルを使うか (When to use Shell)](#いつシェルを使うか-when-to-use-shell)参照)

配列は文字列の順序付きコレクションを格納し、コマンドやループに対しては個々の要素に安全に展開されます。
単一文字列をコマンドへの複数の引数として利用すると、必然的に`eval`や文字列中のクォートの入れ子を誘発するため避けます。

**推奨 (recommended)**

```shell
# An array is assigned using parentheses, and can be appended to
# with +=( … ).
declare -a flags
flags=(--foo --bar='baz')
flags+=(--greeting="Hello ${name}")
mybinary "${flags[@]}"
```

**非推奨 (discouraged)**

```shell
# Don’t use strings for sequences.
flags='--foo --bar=baz'
flags+=' --greeting="Hello world"'  # This won’t work as intended.
mybinary ${flags}
```

```shell
# Command expansions return single strings, not arrays. Avoid
# unquoted expansion in array assignments because it won’t
# work correctly if the command output contains special
# characters or whitespace.

# This expands the listing output into a string, then does special keyword
# expansion, and then whitespace splitting.  Only then is it turned into a
# list of words.  The ls command may also change behavior based on the user's
# active environment!
declare -a files=($(ls /directory))

# The get_arguments writes everything to STDOUT, but then goes through the
# same expansion process above before turning into a list of arguments.
mybinary $(get_arguments)
```

**配列の利点**

* 配列の利用はクォートを錯乱させることなくリストの作成を可能にします。逆に、配列を利用しなければ、文字列中でクォートを入れ子にする誤った試みへつながります
* 配列は、スペースを含む任意の文字列からなるシーケンス/リストの安全な保存を可能にします

**配列の欠点**

* 配列の利用によりスクリプトはより複雑になる可能性があります
* 改行で区切られた文字列出力は配列に変換するためには追加の処理が必要です。変換するよりも素直にループを利用することを検討してください

```shell
# 改行で区切られた文字列出力を配列に変換する
IFS=$'\n' read -r -d '' -a files < <(ls /directory && printf '\0')
```

配列はリストを安全に作成したり渡したりする場合に利用します。特に、コマンド引数のセットを構築する時のように、クォートが錯乱する問題を避ける場合に利用します。配列にアクセスするときはクォート展開`"${array[@]}"`を利用します。しかしながら、もしさらに高度なデータ操作が要求される場合は、そもそもシェルスクリプトの利用は避けましょう。

## whileへのパイプ (Pipes to While)

> **Note** Googleスタイルガイド

* ✔️ DO: プロセス置換か`readarray`ビルトイン(bash4+)を使用して`while`へパイプします
* ❌ DO NOT: `| while`を使用して`while`へパイプしてループすることは避けます

`while`へパイプする場合はプロセス置換か`readarray`ビルトイン (bash4+) を優先的に利用します。プロセス置換はサブシェルを作成しますが、`while`やその他のコマンドをサブシェル内に置くことなくサブシェルから`while`へのリダイレクトを可能にします。一方、パイプはサブシェルを作るためパイプライン中における変数の変更は親シェルに伝播せず、`| while`を用いると追いかけるのが困難な分かりにくいバグを誘引します。

代わりに`readarray`組み込み関数を使用してファイルを配列に読み込み、配列の内容をループすることを検討してください。(上記と同じ理由で)`readarray`に代入するときはパイプではなくプロセス置換を使用する必要があることに注意してください。ただし、ループの入力生成がパイプの後ではなく前に配置されるという利点があります。

**推奨 (recommended)**

```shell
# readarray is most recommended
last_line='NULL'
readarray -t lines < <(ls)
for line in "${lines[@]}"; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done

# This will output the last non-empty line from your_command
echo "${last_line}"
```

```shell
# Process substitution is also acceptable
last_line='NULL'
while read line; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done < <(ls)

# This will output the last non-empty line from your_command
echo "${last_line}"
```

**非推奨 (discouraged)**

```shell
# Pipe won't pass variable changes to outside
last_line='NULL'
ls | while read -r line; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done

# This will always output 'NULL'!
echo "${last_line}"
```

## forループ (For Loops)

> **Note** Googleスタイルガイド

* ✔️ DO: スペースを含ないことが確実な場合、`for`ループを使用してリストをイテレートします
* ✔️ DO: `for`ループを使用してリストをイテレートする場合、`"${array[@]}"`を使用します。この時変数は、配列か改行で区切られた文字列であることを確認してください

forループでイテレートする際は注意が必要です。`for var in $(...)`では、出力は行ではなくスペースで分割します。出力が想定外のスペースを含ないことが分かっているため場合安全ですが、明確でない場合は`while read`ループか`readarray`の方が安全で明確になるでしょう。forループを使用してリストをイテレートする場合、`"${array[@]}"`を使用することでクォート規約を遵守します。

**推奨 (recommended)**

```shell
# use array when itelating space separeted list. (You cannot itelate with string "foo bar piyo")
lines=(foo bar piyo)
for line in "${lines[@]}"; do
  echo "1 ${line}"
done

# use array when itelating line separated outout
lines=$(ls -l)
for line in "${lines[@]}"; do
  echo "1 ${line}"
done
```

**非推奨 (discouraged)**

```shell
# shellckeck warn you SC2206 for quote this
lines="foo bar piyo"
for line in ${lines[@]}; do
  echo "1 ${line}"
done

# Won't work. output is `1 foo bar piyo`
lines="foo bar piyo"
for line in "${lines[@]}"; do
  echo "1 ${line}"
done

# space included lines won't itelate correctly
for line in $(ls -l); do
  echo "1 ${line}"
done
```

## 算術演算 (Arithmetic)

> **Note** Googleスタイルガイド

* ✔️ DO: 算術演算には`(( ... ))`や`$(( ... ))`を利用します
* ❌ DO NOT: `$[]`構文、`let`や`expr`を使用して算術演算しないでください
* ⚠️ CONSIDER: `(( ... ))`を独立した文として利用することは避けてください。代わりに、`if (( ... ))`のように条件式として利用してください
* ⚠️ CONSIDER: `(( ... ))`や`$(( ... ))`内部では変数を`i`のように`$`や`${}`を省略できます

`<`と`>`は`[[ ... ]]`式内部では数値比較として動作せず辞書的比較します。([文字列のテスト (Testing Strings)](#文字列のテスト-testing-strings)参照)。代わりに全ての算術演算に対しては`[[ ... ]]`ではなく、`(( ... ))`を優先的に利用してください。

`(( ... ))`を独立した文として利用する場合、その式がゼロと評価されるか注意が必要なため避けてください。特に`set -e`が有効な場合、`set -e; i=0; (( i++ ))`はシェルを終了させてしまいます。
文法的考慮点を差し置いても、シェルビルトインの算術演算`(())`は多くの場合`expr`よりも高速です。

**推奨 (recommended)**

```shell
# Simple calculation used as text - note the use of $(( … )) within a string.
echo "$(( 2 + 2 )) is 4"

# When performing arithmetic comparisons for testing
if (( a < b )); then
  …
fi

# Some calculation assigned to a variable.
(( i = 10 * j + 400 ))
```

**非推奨 (discouraged)**

```shell
# This form is non-portable and deprecated
i=$[2 * 10]

# Despite appearances, 'let' isn't one of the declarative keywords,
# so unquoted assignments are subject to globbing wordsplitting.
# For the sake of simplicity, avoid 'let' and use (( … ))
let i="2 + 2"

# The expr utility is an external program and not a shell builtin.
i=$( expr 4 + 4 )

# Quoting can be error prone when using expr too.
i=$( expr 4 '*' 4 )

# シェルが終了してしまう
set -e
i=0
(( i++ ))
```

`$(())`で変数を利用する場合、シェルが`var`を変数と認識するため、`${var}`や`$var`は不要です。`${...}`を省略することで読みやすくなるため推奨しますが、この規約は先述のクォート規約と反するため必須ではありません。

**推奨 (recommended)**

```shell
# N.B.: Remember to declare your variables as integers when
# possible, and to prefer local variables over globals.
local -i hundred="$(( 10 * 10 ))"
declare -i five="$(( 10 / 2 ))"

# Increment the variable "i" by three.
# Note that:
#  - We do not write ${i} or $i.
#  - We put a space after the (( and before the )).
(( i += 3 ))

# To decrement the variable "i" by five:
(( i -= 5 ))

# Do some complicated computations.
# Note that normal arithmetic operator precedence is observed.
hr=2
min=5
sec=30
echo "$(( hr * 3600 + min * 60 + sec ))" # prints 7530 as expected
```

# コマンド呼び出し (Calling Commands)

## 返り値判定 (Checking Return Values)

> **Note** Googleスタイルガイド

* ✔️ DO: 返り値は常に判定し、有益な返り値を与えます
* ✔️ DO: コマンドの成否で処理を分ける場合、`if`文で直接判定します
* ❌ DO NOT: `set -euo pipefail`が前提にあるため、`$?`や`PIPESTATUS`変数による返り値判定は避けます


**推奨 (recommended)**

```shell
# ifの中ならコマンドが失敗してもよい
if ! mv "${file_list[@]}" "${dest_dir}/"; then
  echo "Unable to move ${file_list[*]} to ${dest_dir}" >&2
  exit 1
fi
```

**非推奨 (discouraged)**

```shell
# set -euo pipefailなのでmvが失敗した場合、スクリプトは終了する
mv "${file_list[@]}" "${dest_dir}/"
if (( $? != 0 )); then
  echo "Unable to move ${file_list[*]} to ${dest_dir}" >&2
  exit 1
fi

# set -euo pipefailなので、PIPESTATUSは使わない。パイプライン全体でのエラーを判定する。
tar -cf - ./* | (cd "${dir}" && tar -xf -)
if (( PIPESTATUS[0] != 0 || PIPESTATUS[1] != 0 )); then
  echo "Unable to tar files to ${dir}" >&2
fi
```

## エラー処理 (Error Handling)

> **Note** icy/bash-coding-styleベース

* ✔️ DO: 関数内で発生するエラーは関数で処理をします。呼び出し元でエラー処理は避けます

別関数で発生したエラーを呼び出し元で処理することは避けます。関数内でエラーが発生した場合、その関数内でエラー処理を行います。エラー処理は`common::error`関数を用いてエラーメッセージを表示し、`return 1`で関数を終了します。

**推奨 (recommended)**

```shell
_foobar_call() {
  # do something

  if [[ $? -ge 1 ]]; then
    _error "${FUNCNAME[0]} has some internal error"
  fi
}

_my_def() {
  _foobar_call || return 1
}
```

**非推奨 (discouraged)**

```shell
_my_def() {
  _foobar_call

  if [[ $? -ge 1 ]]; then
    echo >&2 "_foobar_call has some error"
    _error "_foobar_call has some error"
    return 1
  fi
}
```

## ビルトインコマンド vs 外部コマンド (Builtin Commands vs. External Commands)

> **Note** Googleスタイルガイド

* ✔️ DO: シェルビルトイン呼び出しか分離プロセス呼び出しかの選択を迫られたら、ビルトインを選択します
* ❌ DO NOT: bashの変数展開を複雑に駆使するのとsedなど標準的な外部コマンドでシンプルにかける場合、ビルトインコマンドに固執するのは避けてください

シェルビルトインは、外部コマンドと比べて堅牢かつポータル(例えば`sed`はBSDとGNUで異なる)であるため、bash(1)にある変数展開機能のようなビルトインの利用は適切です。しかしながら、外部コマンドの標準的な利用がシンプルである場合、ビルトインコマンドに固執する必要はありません。特に複雑な変数展開を用いると他の開発者がコードを理解するのに時間を要する可能性があります。

**推奨 (recommended)**

```bash
addition=$(( X + Y ))
substitution="${string/#foo/bar}"
```

**非推奨 (discouraged)**

```shell
addition="$(expr "${X}" + "${Y}")"
substitution="$(echo "${string}" | sed -e 's/^foo/bar/')"
```

# スクリプトの安定化 (Script Stabilization)

スタイルガイドを守ってもスクリプトの安定化は約束できません。よくあるスクリプトの安定化にのためのベストプラクティスを示します。


## 再実行可能なスクリプトを書く (Writing Rerunnable Scripts)

> **Note** 独自規約

* ✔️ DO: スクリプトを同じ引数で実行したときに同じ結果が得られるようにします

冪等性のあるコードを書くことは重要です。冪等性=スクリプトを何度実行しても同じ結果が得られため、スクリプトの途中で処理が失敗した場合でも再実行により続きから処理を行えるようになります。冪等性を意識することで、より信頼性の高い、メンテナンスしやすいスクリプトを作成できます。

**推奨 (recommended)**

```shell
# このスクリプトは冪等性がある
name="実行ごとに渡すID/ファイル名"
mkdir -p "$(dirname "${name}")"
if [[ ! -f "${name}" ]]; then
  # ファイルがあってもなくてもコンテンツが初期化されてから追記される
  echo "nanika" > "${name}"
  echo "okonomiyaki" >> "${name}"
  echo "takoyaki" >> "${name}"
fi

# kubectl applyは再実行性があるコマンドなので活用する
kubectl apply -f ./manifest.yaml
```

**非推奨 (discouraged)**

```shell
# 初回にディレクトリの存在があっても次にある可能性が保証されていない
name="実行ごとに渡すID/ファイル名"
if [[ ! -f "${name}" ]]; then
  # 前のファイルがあると追記されて同じ結果にならない
  echo "nanika" >> "${name}"
  echo "okonomiyaki" >> "${name}"
  echo "takoyaki" >> "${name}"
fi

# kubectl createは再実行性が担保されていないのですでに存在するとエラーになる
kubectl create nanika
```

## 変更前に状態の確認を行う (Check State Before Changing)

> **Note** 独自規約

* ✔️ DO: 変更前に状態を確認し意図したコマンドが実行されることを担保します

システムの状態を変更する操作する場合、すでに目的の状態になっているかどうかを最初にチェックすることで、不要な処理を避けエラーを防ぎます。

**推奨 (recommended)**

```shell
# 変数が空かどうかチェックしてから処理を行う
if [[ "${kubemanifest}" == "" ]]; then
  common::error "kubernetes manifest not generated. exit script."
  exit 1
fi

echo "${kubemanifest}" | kubectl apply -f -
```

**非推奨 (discouraged)**

```shell
# 何もチェックせずに処理を行う。kubemanifestが空の場合、意図しない結果になる
echo "${kubemanifest}" | kubectl apply -f -
```

## 一時ファイルの安全な作成 (Safely Creating Temporary Files)

> **Note** 独自規約

* ✔️ DO: 一時ファイルの作成には`mktemp`を使用します
* ⚠️ CONSIDER: スクリプト終了時には`trap`を使用して確実に削除できないか検討します

mktempを使用することで、安全に一時ファイルを作成でき、trapを使用することでスクリプト終了時に確実に削除できます。

**推奨 (recommended)**

```shell
# mktemp を使用して安全に一時ファイルを作成
temp_file=$(mktemp)

# スクリプトの終了時に一時ファイルを削除
trap 'rm -f "$temp_file"' EXIT

# 一時ファイルを使用した処理が安全にかける
```

**非推奨 (discouraged)**

```shell
# 独自ルールの一時ファイル作成は重複を考慮するのが難しい
temp_file=$(/tmp/foobar_$(date +%s))

# 一時ファイルを使用した処理をここに記述

# ファイルの削除漏れが発生する可能性がある
rm "${temp_file}"
```
