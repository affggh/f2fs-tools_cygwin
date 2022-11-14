#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import errno
import shutil
import stat
import struct
import subprocess
import argparse
import sys
import os
import platform

is_windows = True if os.name == 'nt' else False
exe = ".exe" if os.name == 'nt' else ""
bb = make_f2fs = os.path.join(
    os.path.dirname(__file__), platform.system(), 'bin', 'busybox' + exe)
make_f2fs = os.path.join(os.path.dirname(
    __file__), platform.system(), 'bin', 'make_f2fs' + exe)
sload_f2fs = os.path.join(os.path.dirname(
    __file__),  platform.system(), 'bin', 'sload_f2fs' + exe)


def mv(source, target):
    try:
        shutil.move(source, target)
    except:
        pass


def cp(source, target):
    try:
        shutil.copyfile(source, target)
    except:
        pass


def rm(file):
    try:
        os.remove(file)
    except OSError as e:
        if e.errno != errno.ENOENT:
            raise


def rm_on_error(func, path, _):
    # Remove a read-only file on Windows will get "WindowsError: [Error 5] Access is denied"
    # Clear the "read-only" and retry
    os.chmod(path, stat.S_IWRITE)
    os.unlink(path)


def rm_rf(path):
    shutil.rmtree(path, ignore_errors=True, onerror=rm_on_error)


def mkdir(path, mode=0o755):
    try:
        os.mkdir(path, mode)
    except:
        pass


def mkdir_p(path, mode=0o755):
    os.makedirs(path, mode, exist_ok=True)


def system(cmd, STDOUT=sys.stdout, STDERR=sys.stderr, env=None):
    return subprocess.run(cmd, shell=True, stdout=STDOUT, stderr=STDERR, env=env)


def cmd_out(cmd, env=None) -> str:
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, env=env) \
                     .stdout.strip().decode('utf-8')


class ImageUtils(object):
    def make_f2fs_image(self, out: str, size: str, src: str, mount_point: str = "/", sparse: bool = False, compress: bool = False):
        rm_rf(out)

        if not size:
            print(f'参数: size={size}, error')
            sys.exit(1)
        if not src:
            print(f'参数: size={src}, error')
            sys.exit(1)
        if not os.path.isdir(src):
            print(f'{src} not directory')
            sys.exit(1)
        if not os.path.exists(src):
            print(f'{src} not exists')
            sys.exit(1)

        _size = ""
        if size.endswith(("G", "g")):
            if len(str(size)) > 2:
                _size = (int(size[0:-2]) * 1024 + 6) * 1024 * 1024
            else:
                _size = (int(size[0]) * 1024 + 6) * 1024 * 1024
        elif size.endswith(("M", "m")):
            _size = (int(size[0:-2]) + 6) * 1024 * 1024
        else:
            _size = size

        # make_f2fs cmd
        make_f2fs_cmd = [make_f2fs, "-g", "android"]
        if sparse:
            make_f2fs_cmd.extend(["-S", str(_size)])
        if compress:
            make_f2fs_cmd.extend(["-O", "compression,extra_attr"])
        make_f2fs_cmd.extend(["-l", mount_point])
        make_f2fs_cmd.append(out)

        # sload_f2fs cmd
        sload_f2fs_cmd = [sload_f2fs, "-f", src]
        sload_f2fs_cmd.extend(["-t", mount_point])
        sload_f2fs_cmd.extend(["-T", "1230768000"])
        if compress:
            sload_f2fs_cmd.append("-c")
        sload_f2fs_cmd.append(out)

        # run cmd
        if not sparse:
            if is_windows:
                system(f'{bb} dd if=/dev/zero of={out} bs={str(_size)} count=1')
            else:
                system(f'truncate -s {_size} {out}')
        print(" ".join(make_f2fs_cmd))
        make_empty_image = system(" ".join(make_f2fs_cmd))
        if make_empty_image.returncode == 0:
            print(" ".join(sload_f2fs_cmd))
            sload_image = system(" ".join(sload_f2fs_cmd))

    def check_f2fs_image(self, image, offest=1024, data_length=4) -> bool:
        F2FS_MAGIC = 0xF2F52010
        with open(image, 'rb') as f:
            f.seek(offest, 0)
            data = struct.unpack('<I', f.read(data_length))
            f.seek(0, 0)
            if F2FS_MAGIC == data:
                return True
            else:
                return False


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Make the f2fs filesystem image')

    parser.add_argument('--out', default='f2fs.img',
                        help='path to repack image')
    parser.add_argument('--size', help='repack image size: G M bytes')
    parser.add_argument('--src', help='repack image src dir')
    parser.add_argument('--mount_point', default="/", help='image mount label')
    parser.add_argument('--sparse', action='store_true',
                        help='repack image enable sparse format image')
    parser.add_argument('--compress', action='store_true',
                        help='repack image enable f2fs compress data')
    parser.add_argument('--check_image',
                        help='check image with f2fs format')
    args = parser.parse_args()
    input_image = args.check_image

    image_utils = ImageUtils()
    if input_image:
        is_f2fs_fromat = image_utils.check_f2fs_image(input_image)
        if is_f2fs_fromat:
            print(f'{input_image} is f2fs image')
        sys.exit(0)

    image_utils.make_f2fs_image(args.out, args.size, args.src,
                                mount_point=args.mount_point, sparse=args.sparse, compress=args.compress)
