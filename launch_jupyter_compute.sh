# Compute node
LOG=sunpyter_log.txt
touch $LOG
sbatch --partition development -A scw1000 -o $LOG -J SUNPYTER -n 1 jupyter notebook --no-browser --ip='*'
tail -f $LOG

