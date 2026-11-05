#!/usr/bin/env python3
"""Capture only appearance files; never collect user history or credentials."""
from pathlib import Path
import argparse,datetime,fnmatch,hashlib,json,os,shutil,subprocess

SKIP = ['.git','__pycache__','backups','*.backup*','*.bak','*.pyc','*.log','*~']
CONFIGS = ['hypr','waybar','swaync','rofi','kitty','gtk-3.0','gtk-4.0','nwg-look','xsettingsd']

def copy_tree(source,destination):
    if source.is_dir():
        shutil.copytree(source,destination,dirs_exist_ok=True,symlinks=False,
                        ignore=lambda folder,names:[n for n in names if any(fnmatch.fnmatch(n,p) for p in SKIP)])
    elif source.is_file():
        destination.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,destination)

def manifest(repo):
    entries=[]
    for category in ['home','shell','system']:
        base=repo/category
        if not base.exists():continue
        for path in sorted(base.rglob('*')):
            if not path.is_file():continue
            entries.append({'source':str(path.relative_to(repo)),'destination':str(path.relative_to(base)),
                            'category':category,'mode':path.stat().st_mode & 0o777,
                            'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
    (repo/'manifest.json').write_text(json.dumps({'format':1,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':entries},indent=2)+'\n')

def snapshot(repo,home):
    repo.mkdir(parents=True,exist_ok=True)
    for name in CONFIGS:copy_tree(home/'.config'/name,repo/'home/.config'/name)
    for name in ['wallpaper','papirus-folders']:copy_tree(home/'.local/bin'/name,repo/'home/.local/bin'/name)
    copy_tree(home/'.local/share/nwg-look',repo/'home/.local/share/nwg-look')
    copy_tree(home/'.local/share/wallpapers',repo/'home/.local/share/wallpapers')
    gtk=Path('/usr/share/themes/Everforest-Green-Dark')
    if not gtk.exists():gtk=home/'.local/share/themes/Everforest-Green-Dark'
    copy_tree(gtk,repo/'home/.local/share/themes/Everforest-Green-Dark')
    # Supplement launcher artwork missing from the active Rofi config, if available locally.
    artwork=home/'rofi/files/images'
    if artwork.exists():copy_tree(artwork,repo/'home/.config/rofi/images')
    for name in ['.zshrc','.p10k.zsh']:copy_tree(home/name,repo/'shell'/name)
    # Keep just visual KDE settings, excluding file-dialog locations and application history.
    kde=home/'.config/kdeglobals'
    if kde.exists():
        selected=[]; keep=False
        for line in kde.read_text().splitlines():
            if line.startswith('['):
                keep=line.startswith(('[ColorEffects:','[Colors:','[General]','[Icons]','[KDE]','[WM]'))
            if keep:selected.append(line)
        dest=repo/'home/.config/kdeglobals';dest.write_text('\n'.join(selected)+'\n')
    copy_tree(Path('/usr/share/sddm/themes/everforest-minimal'),repo/'system/usr/share/sddm/themes/everforest-minimal')
    copy_tree(Path('/etc/sddm.conf.d/90-everforest.conf'),repo/'system/etc/sddm.conf.d/90-everforest.conf')
    # Preserve the active image outside Downloads and make its location portable.
    query=subprocess.run(['awww','query'],capture_output=True,text=True)
    images=[]
    if query.returncode==0:
        for line in query.stdout.splitlines():
            if 'image: ' in line:
                image=Path(line.split('image: ',1)[1])
                if image.is_file() and image not in images:images.append(image)
    for i,image in enumerate(images):
        target=repo/'home/.local/share/wallpapers'/('saved-current'+('' if i==0 else '-'+str(i))+image.suffix.lower())
        copy_tree(image,target)
    snippet=repo/'home/.config/everforest/path.zsh';snippet.parent.mkdir(parents=True,exist_ok=True)
    snippet.write_text('# Personal desktop commands\ntypeset -U path\npath=("$HOME/.local/bin" $path)\nexport PATH\n')
    packages=repo/'packages';packages.mkdir(exist_ok=True)
    installed=subprocess.run(['pacman','-Q'],capture_output=True,text=True)
    (packages/'installed-versions.txt').write_text(installed.stdout)
    template=Path(__file__).resolve().parent.parent
    if (template/'restore.py').exists():
        for name in ['README.md','restore.py','docs','scripts','licenses','.gitignore']:
            copy_tree(template/name,repo/name)
        for name in ['official.txt','optional.txt','aur-optional.txt']:
            copy_tree(template/'packages'/name,repo/'packages'/name)
    manifest(repo)
    print('Snapshot complete:',repo)
    print('Files:',len(json.loads((repo/'manifest.json').read_text())['files']))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',required=True,type=Path)
    parser.add_argument('--source-home',type=Path,default=Path.home())
    args=parser.parse_args()
    if args.output.exists() and any(args.output.iterdir()):parser.error('Use a new, empty output directory.')
    snapshot(args.output.resolve(),args.source_home.resolve())
