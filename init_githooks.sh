#! /bin/sh
#
# Initialize the local git hooks this repository.
# https://git-scm.com/docs/githooks

topLevel=$(git rev-parse --show-toplevel) && cd "${topLevel}"
hooksDir="${topLevel}/.githooks"
hooksPath=$(git config core.hooksPath)
if [ $? -ne 0 ]; then
	hooksPath="${topLevel}/.git/hooks"
fi

echo "linking hooks..."
for hook in \
  applypatch-msg \
  pre-applypatch \
  post-applypatch \
  pre-commit \
  pre-merge-commit \
  prepare-commit-msg \
  commit-msg \
  post-commit \
  pre-rebase \
  post-checkout \
  post-merge \
  pre-push \
  pre-receive \
  update \
  post-receive \
  post-update \
  push-to-checkout \
  pre-auto-gc \
  post-rewrite \
  sendemail-validate \
  fsmonitor-watchman \
  p4-pre-submit \
  post-index-change
do
	src="${hooksDir}/${hook}"
  dest="${hooksPath}/${hook}"

	[ -x "${src}" ] || continue

	echo "- ${hook}"
	ln -sf "${src}" "${dest}"
done
