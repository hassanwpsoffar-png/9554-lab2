
DIR = test_dir
MALICIOUS_DIR = quarantine
INTERVAL_SECS = 5

.PHONY: all pre-build antivirusd restore

all: pre-build

pre-build:
	mkdir -p $(MALICIOUS_DIR)

antivirusd: pre-build
	bash antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL_SECS)

restore: pre-build
	bash restore.sh $(DIR) $(MALICIOUS_DIR)
