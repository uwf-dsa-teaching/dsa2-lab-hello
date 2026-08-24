SHELL := /bin/bash
CXX = g++
CXXFLAGS = -std=c++14 -Wall -Wextra -Wno-sign-compare
RM = rm -rf

.PHONY: make-main test-run test-output test-all test-mem clean

make-main:
	@if [ -f "Makefile" ]; then \
		make -f Makefile main ; \
	elif [ -f "makefile" ]; then \
		make -f makefile main ; \
	else \
		echo "No Makefile or makefile found!"; \
		exit 1; \
	fi ; \
	CODE=$$? ; \
	if [ $$CODE -eq 0 ] && [ -e "main" ]; then \
		echo "Successfully compiled main!"; \
	else \
		echo "Cannot compile main using \"make\"!"; \
		exit 1; \
	fi

test-run: make-main
	@echo "Test running main ..."
	@./main > /dev/null 2>&1 ; \
	if [ $$? -eq 0 ]; then \
		echo "The run of ./main exit successfully!"; \
	else \
		echo "The run of ./main exit with error!"; \
		exit 1; \
	fi

test-output: make-main
	@echo "Checking output format..."
	@OUTPUT=$$(./main) ; \
	echo "$$OUTPUT" > output.txt ; \
	if echo "$$OUTPUT" | grep -qE '^[A-Za-z0-9\-]+:[A-Za-z0-9]+$$' && echo "$$OUTPUT" | grep -q 'Hello World!'; then \
		echo "Output is valid."; \
		rm -f output.txt ; \
	else \
		if ! echo "$$OUTPUT" | grep -qE '^[A-Za-z0-9\-]+:[A-Za-z0-9]+$$'; then \
			echo "Output does not contain valid ID format"; \
		fi ; \
		if ! echo "$$OUTPUT" | grep -q 'Hello World!'; then \
			echo "Output does not contain 'Hello World!'"; \
		fi ; \
		rm -f output.txt ; \
		exit 1; \
	fi

test-all: test-run test-output

test-mem: make-main
	valgrind --error-exitcode=1 --leak-check=full ./main

clean:
	$(RM) -f *.o *.gch main output.txt
	$(RM) -rf *.dSYM
