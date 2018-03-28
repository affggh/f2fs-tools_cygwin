#include <stdio.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/syscall.h>
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <string.h>
#include <stdlib.h>

#define F2FS_IOCTL_MAGIC		0xf5
#define F2FS_IOC_START_ATOMIC_WRITE     _IO(F2FS_IOCTL_MAGIC, 1)
#define F2FS_IOC_COMMIT_ATOMIC_WRITE    _IO(F2FS_IOCTL_MAGIC, 2)
#define F2FS_IOC_START_VOLATILE_WRITE   _IO(F2FS_IOCTL_MAGIC, 3)
#define F2FS_IOC_RELEASE_VOLATILE_WRITE _IO(F2FS_IOCTL_MAGIC, 4)
#define F2FS_IOC_ABORT_VOLATILE_WRITE   _IO(F2FS_IOCTL_MAGIC, 5)
#define F2FS_IOC_GARBAGE_COLLECT        _IO(F2FS_IOCTL_MAGIC, 6)

#define DB1_PATH "/data/database_file1"
#define DB2_PATH "/sdcard/database_file2"

#define BLOCK 4096
#define BLOCKS (2 * BLOCK)

int buf[BLOCKS];
char cmd[BLOCK];

static int run(char *cmd)
{
	int status;

	fflush(stdout);

	switch (fork()) {
	case 0:
		/* redirect stderr to stdout */
		dup2(1, 2);
		execl("/system/bin/sh", "sh", "-c", cmd, (char *) 0);
	default:
		wait(&status);
	}
}

static int test_atomic_write(char *path)
{
	int db, ret, written, i;

	printf("\tOpen  %s... \n", path);
	db = open(path, O_RDWR|O_CREAT);
	if (db < 0) {
		printf("open failed errno:%d\n", errno);
		return -1;
	}
	printf("\tStart ... \n");
	ret = ioctl(db, F2FS_IOC_START_ATOMIC_WRITE);
	if (ret) {
		printf("ioctl failed errno:%d\n", errno);
		return -1;
	}
	printf("\tWrite to the %dkB ... \n", BLOCKS / 1024);
	written = write(db, buf, BLOCKS);
	if (written != BLOCKS) {
		printf("write fail written:%d, errno:%d\n", written, errno);
		return -1;
	}
	printf("\tCheck : Atomic in-memory count: 2\n");
	run("cat /sys/kernel/debug/f2fs/status | grep atomic");

	printf("\tCommit  ... \n");
	ret = ioctl(db, F2FS_IOC_COMMIT_ATOMIC_WRITE);
	if (ret) {
		printf("ioctl failed errno:%d\n", errno);
		return -1;
	}
	return 0;
}

int main(int argc, char **argv)
{
	int db, ret, written, i;

	memset(buf, 0xff, BLOCKS);

	printf("# Test 0: Check F2FS support\n");
	run("cat /proc/filesystems");

	printf("# Test 1: Check F2FS status on /userdata\n");
	printf("\t= FS type /userdata\n");
	run("mount | grep data");

	printf("\n\t= F2FS features\n");
	run("ls -1 /sys/fs/f2fs/features/");
	run("find /sys/fs/f2fs -type f -name \"features\" -print -exec cat {} \\;");
	run("find /sys/fs/f2fs -type f -name \"ipu_policy\" -print -exec cat {} \\;");
	run("find /sys/fs/f2fs -type f -name \"discard_granularity\" -print -exec cat {} \\;");
	run("cat /sys/kernel/debug/f2fs/status");

	printf("\n\n# Test 2: Atomic_write on /userdata\n");
	if (test_atomic_write(DB1_PATH))
		return -1;

	printf("# Test 3: Atomic_write on /sdcard\n");
	if (test_atomic_write(DB2_PATH))
		return -1;
	return 0;
}
