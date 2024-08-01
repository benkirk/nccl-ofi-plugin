.PHONY: run

plugin := install/plugin/lib/libnccl-net.so

$(plugin): build_derecho.sh
	./$< | tee build_derecho.log

run: run_tests_derecho.sh env_nccl_derecho.sh $(plugin)
	qsub $<

clean:
	rm -f *.log* *.sh.o*

distclean:
	rm -rf aws-ofi-nccl/ nccl/ nccl-tests/
	git clean -xdf .
