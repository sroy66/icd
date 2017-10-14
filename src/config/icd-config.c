#ifndef CONFIG_H_INCLUDED
#include "config.h"

/**
 * All this is to keep Vala happy & configured..
 */
const char *ICD_DATADIR = DATADIR;
const char *ICD_CONFDIR = SYSCONFDIR;
const char *ICD_TEMPLATEDIR = TEMPLATEDIR;
const char *ICD_VERSION = PACKAGE_VERSION;
const char *ICD_WEBSITE = PACKAGE_URL;
const char *ICD_GETTEXT_PACKAGE = GETTEXT_PACKAGE;

#else
#error config.h missing!
#endif
