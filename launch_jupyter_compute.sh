# Compute node
LOG=~/sunpyter_log.txt
rm -r $LOG
touch $LOG
chmod go-r $LOG
sbatch --partition development -A SEDACCOUNT -o $LOG -J SUNPYTER --dependency=singleton -n 1 --oversubscribe jupyter notebook --no-browser --ip='*'
tail -f $LOG

