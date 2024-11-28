#include <errno.h>
#include <fcntl.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <unistd.h>

#include <libtablet2multitouch.h>

#define LOG_TAG "tablet2multitouch"

#ifdef DEBUG
#define LOG_ERROR(...) fprintf(stderr, LOG_TAG ": " __VA_ARGS__)
#define LOG_INFO(...) fprintf(stdout, LOG_TAG ": " __VA_ARGS__)
#else
#include <cutils/klog.h>
#define LOG_ERROR(...) KLOG_ERROR(LOG_TAG, __VA_ARGS__)
#define LOG_INFO(...) KLOG_INFO(LOG_TAG, __VA_ARGS__)
#endif

int main() {
    int fd, uinput_fd;
    struct input_event ev;
    struct input_absinfo abs_x_info, abs_y_info;
    const char* device_names[] = {"QEMU QEMU USB Tablet", "QEMU Virtio Tablet"};
    char device_path[64];
    int epoll_fd;
    struct epoll_event event, events[10];

    // Find the evdev device path
    for (int i = 0; i < 64; ++i) {
        snprintf(device_path, sizeof(device_path), "/dev/input/event%d", i);
        fd = open(device_path, O_RDONLY | O_NONBLOCK);
        if (fd < 0) continue;

        ioctl(fd, EVIOCGNAME(sizeof(device_path)), device_path);

        for (int j = 0; j < sizeof(device_names) / sizeof(device_names[0]); ++j) {
            if (strcmp(device_path, device_names[j]) == 0) {
                goto device_found;
            }
        }

        close(fd);
        fd = -1;
    }

    if (fd < 0) {
        LOG_ERROR("Device not found\n");
        return EXIT_SUCCESS;
    }

device_found:
    LOG_INFO("Using device: %s\n", device_path);

    // Read ABS_X and ABS_Y info from the source device
    if (ioctl(fd, EVIOCGABS(ABS_X), &abs_x_info) < 0) {
        LOG_ERROR("ioctl EVIOCGABS(ABS_X)\n");
        return EXIT_FAILURE;
    }

    if (ioctl(fd, EVIOCGABS(ABS_Y), &abs_y_info) < 0) {
        LOG_ERROR("ioctl EVIOCGABS(ABS_Y)\n");
        return EXIT_FAILURE;
    }

    // Setup uinput device
    if (libtablet2multitouch_setup_uinput_device(&uinput_fd, &abs_x_info, &abs_y_info) < 0) {
        LOG_ERROR("Failed to setup uinput device\n");
        return EXIT_FAILURE;
    }

    // Setup epoll
    epoll_fd = epoll_create1(0);
    if (epoll_fd < 0) {
        LOG_ERROR("epoll_create1\n");
        return EXIT_FAILURE;
    }

    event.events = EPOLLIN;
    event.data.fd = fd;
    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, &event) < 0) {
        LOG_ERROR("epoll_ctl\n");
        return EXIT_FAILURE;
    }

    while (1) {
        int ret = epoll_wait(epoll_fd, events, 10, -1);

        if (ret > 0) {
            for (int i = 0; i < ret; ++i) {
                if (events[i].events & EPOLLIN) {
                    int rc = read(fd, &ev, sizeof(ev));
                    if (rc == sizeof(ev)) {
                        libtablet2multitouch_handle_event(uinput_fd, &ev);
                    } else if (rc < 0 && errno != EAGAIN) {
                        LOG_ERROR("read\n");
                        break;
                    }
                }
            }
        } else if (ret < 0) {
            LOG_ERROR("epoll_wait\n");
            break;
        }
    }

    ioctl(uinput_fd, UI_DEV_DESTROY);
    close(uinput_fd);
    close(fd);
    close(epoll_fd);

    return EXIT_SUCCESS;
}
