#!/usr/bin/env python3
"""Restore the Everforest desktop snapshot, with a dry run and per-file backups."""
import argparse,datetime,hashlib,json,os,shutil,tempfile
from pathlib import Path
REPO=Path(__file__).resolve().parent

def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def relative(name):
    path=Path(name)
    if path.is_absolute() or '..' in path.parts:raise ValueError('Unsafe relative path: '+name)
    return path

def check_parent(target,home):
    target.parent.resolve().relative_to(home.resolve())

def atomic_copy(source,target,mode):
    target.parent.mkdir(parents=True,exist_ok=True)
    fd,temp=tempfile.mkstemp(prefix='.everforest-',dir=target.parent)
    os.close(fd)
    try:
        shutil.copyfile(source,temp);os.chmod(temp,mode);os.replace(temp,target)
    finally:
        if Path(temp).exists():Path(temp).unlink()

def rollback(args):
    backup=args.rollback.resolve()
    state=json.loads((backup/'state.json').read_text())
    home=args.target_home.resolve()
    if str(home)!=state['target_home']:raise ValueError('Backup belongs to a different target home.')
    # Do not silently discard edits made since restoring the snapshot.
    for row in state['files']:
        target=home/relative(row['path']);check_parent(target,home)
        if not target.is_file() or target.is_symlink() or digest(target)!=row['installed_sha256']:
            raise ValueError('File changed since restore; save it before rollback: '+str(target))
    if not args.apply:
        print('Dry run: would roll back',len(state['files']),'files from',backup);return
    for row in reversed(state['files']):
        target=home/relative(row['path'])
        if row['existed']:
            saved=backup/'previous'/relative(row['path'])
            target.unlink(missing_ok=True)
            shutil.copy2(saved,target,follow_symlinks=False)
        else:target.unlink(missing_ok=True)
    print('Rolled back',len(state['files']),'files. Log out and back in when ready.')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    action=parser.add_mutually_exclusive_group()
    action.add_argument('--apply',action='store_true',help='write files after backing up the existing versions')
    action.add_argument('--dry-run',action='store_true',help='show the plan only (default)')
    parser.add_argument('--include-shell',action='store_true',help='also replace .zshrc and .p10k.zsh with the captured versions')
    parser.add_argument('--target-home',type=Path,default=Path.home(),help='destination home directory; useful for testing')
    parser.add_argument('--rollback',type=Path,help='undo an earlier restore using its backup directory')
    args=parser.parse_args()
    if args.rollback:return rollback(args)
    manifest=json.loads((REPO/'manifest.json').read_text())
    home=args.target_home.expanduser().resolve()
    selected=[row for row in manifest['files'] if row['category']=='home' or (args.include_shell and row['category']=='shell')]
    blocked_parents=set()
    for row in selected:
        source=REPO/relative(row['source']);target=home/relative(row['destination'])
        if source.is_symlink() or not source.is_file() or digest(source)!=row['sha256']:
            raise ValueError('Snapshot checksum mismatch: '+row['source'])
        try:check_parent(target,home)
        except ValueError:
            blocked_parents.add(str(target.parent))
        if target.exists() and target.is_dir():raise ValueError('Destination is a directory: '+str(target))
    print('Destination:',home)
    print('Files:',len(selected),'(desktop'+(' and shell)' if args.include_shell else ' only)'))
    print('SDDM/system files are handled separately by scripts/install-sddm.sh.')
    if blocked_parents:
        print('Existing symlinked directories point outside the target home:')
        for parent in sorted(blocked_parents)[:5]:print('  '+parent)
        print('Move the existing GTK/config directory aside before applying; see docs/RESTORE.md.')
        if args.apply:raise ValueError('Refusing to write through an external directory symlink.')
    if not args.apply:
        for row in selected[:15]:print('  '+row['destination'])
        print('  ...\nDry run only. Add --apply to restore; existing files will be backed up.');return
    backup=home/'.local/state/everforest-dotfiles/backups'/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup.mkdir(parents=True)
    state={'target_home':str(home),'files':[]}
    def save_state(): (backup/'state.json').write_text(json.dumps(state,indent=2)+'\n')
    def replace(source,target,mode):
        rel=target.relative_to(home);existed=target.exists() or target.is_symlink()
        if existed:
            saved=backup/'previous'/rel;saved.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(target,saved,follow_symlinks=False)
        atomic_copy(source,target,mode)
        state['files'].append({'path':str(rel),'existed':existed,'installed_sha256':digest(target)})
        save_state()
    for row in selected: replace(REPO/row['source'],home/row['destination'],row['mode'])
    # Make personal commands available without replacing an existing shell setup.
    if not args.include_shell:
        zshrc=home/'.zshrc';check_parent(zshrc,home)
        existing=zshrc.read_text() if zshrc.exists() else ''
        line='source "$HOME/.config/everforest/path.zsh"'
        if line not in existing:
            with tempfile.TemporaryDirectory() as tmp:
                source=Path(tmp)/'zshrc';source.write_text(existing+'\n# Everforest desktop commands\n'+line+'\n')
                replace(source,zshrc,0o644)
    print('Restored successfully. Backup:',backup)
    print('Review monitors.lua and the network interface before your next login.')
    print('No packages were installed, no services restarted, and no session was ended.')

if __name__=='__main__':
    try:main()
    except (ValueError,OSError,KeyError) as error:
        raise SystemExit('restore: '+str(error))
