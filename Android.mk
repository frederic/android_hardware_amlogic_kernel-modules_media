#
# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_PREBUILT_KERNEL),)
MEDIA_PATH    := $(abspath $(call my-dir))/drivers
MEDIA_CONFIGS := \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG12=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG2_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG4=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG4_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_VC1=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264_MVC=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H265=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_VP9=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MJPEG=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MJPEG_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_REAL=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AV1=m \
    CONFIG_AMLOGIC_MEDIA_VENC_H264=m \
    CONFIG_AMLOGIC_MEDIA_VENC_JPEG=m \
    CONFIG_AMLOGIC_MEDIA_VENC_H265=m

include $(CLEAR_VARS)

LOCAL_MODULE        := media
LOCAL_MODULE_SUFFIX := .ko
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_CFLAGS        := -Wno-error=pointer-sign -Wno-error=frame-larger-than=

_media_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_media_ko := $(_media_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
MEDIA_CFLAGS := $(LOCAL_CFLAGS)

$(_media_ko): $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/$(BOARD_KERNEL_IMAGE_NAME)
	@mkdir -p $(dir $@)
	@cp -R $(MEDIA_PATH)/* $(_media_intermediates)/
	$(hide) +$(KERNEL_MAKE_CMD) $(PATH_OVERRIDE) $(KERNEL_MAKE_FLAGS) -C $(KERNEL_OUT) M=$(abspath $(_media_intermediates)) ARCH=$(TARGET_KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) EXTRA_CFLAGS="$(MEDIA_CFLAGS)" $(MEDIA_CONFIGS) modules
	modules=$$(find $(_media_intermediates) -type f -name '*.ko'); \
	for f in $$modules; do \
		$(KERNEL_TOOLCHAIN_PATH)strip --strip-unneeded $$f; \
		cp $$f $(KERNEL_MODULES_OUT)/lib/modules; \
	done;
	touch $(_media_intermediates)/media.ko

include $(BUILD_SYSTEM)/base_rules.mk
endif
