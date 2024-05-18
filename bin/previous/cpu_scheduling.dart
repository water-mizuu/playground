typedef Process = ({String id, int arrivalTime, int burstTime, int? priority});
typedef ProcessSpan = ({int start, int end, String id});

enum CpuState { waiting, running }

Iterable<ProcessSpan> firstComeFirstServe(List<Process> processes) sync* {
  List<bool> completedProcesses = List<bool>.filled(processes.length, false);
  List<(int index, Process process)> queue = <(int index, Process process)>[];

  CpuState state = CpuState.waiting;

  (int index, Process process, int start, int span)? currentRunning;
  int currentTime = 0;

  bool run = true;
  do {
    run = false;

    for (int i = 0; i < processes.length; ++i) {
      Process process = processes[i];
      if (!completedProcesses[i] && process.arrivalTime == currentTime) {
        queue.add((i, process));
      }
    }

    switch ((state, currentRunning)) {
      case (CpuState.waiting, null):
        if (queue.isNotEmpty) {
          var (int index, Process process) = queue.removeAt(0);
          currentRunning = (index, process, currentTime, 1);
          state = CpuState.running;
        }
        currentTime++;
      case (CpuState.running, (int index, Process process, int start, int span)):
        if (span == process.burstTime) {
          /// The process has completed.
          completedProcesses[index] = true;
          yield (start: start, end: currentTime, id: process.id);

          /// Reset the state machine.
          currentRunning = null;
          state = CpuState.waiting;
        } else {
          currentRunning = (index, process, start, span + 1);

          currentTime++;
        }
      case _:
        throw StateError("Invalid State!");
    }

    for (bool boolean in completedProcesses) {
      run |= !boolean;
    }
  } while (run);
}

Iterable<ProcessSpan> shortestProcessFirst(List<Process> processes) sync* {
  List<bool> completedProcesses = List<bool>.filled(processes.length, false);
  List<(int index, Process process)> queue = <(int index, Process process)>[];

  CpuState state = CpuState.waiting;

  (int index, Process process, int start, int span)? currentRunning;
  int currentTime = 0;

  bool run = true;
  do {
    run = false;

    for (int i = 0; i < processes.length; ++i) {
      Process process = processes[i];
      if (!completedProcesses[i] && process.arrivalTime == currentTime) {
        queue.add((i, process));
      }
    }

    switch ((state, currentRunning)) {
      case (CpuState.waiting, null):
        if (queue.isNotEmpty) {
          int chosenIndex = 0;
          (int index, Process process) chosen = queue.first;
          for (int i = 0; i < queue.length; ++i) {
            if (queue[i].$2.burstTime < chosen.$2.burstTime) {
              chosenIndex = i;
              chosen = queue[i];
            }
          }
          queue.removeAt(chosenIndex);

          var (int index, Process process) = chosen;
          currentRunning = (index, process, currentTime, 1);
          state = CpuState.running;
        }
        currentTime++;
      case (CpuState.running, (int index, Process process, int start, int span)):
        if (span == process.burstTime) {
          /// The process has completed.
          completedProcesses[index] = true;
          yield (start: start, end: currentTime, id: process.id);

          /// Reset the state machine.
          currentRunning = null;
          state = CpuState.waiting;
        } else {
          currentRunning = (index, process, start, span + 1);

          currentTime++;
        }
      case _:
        throw StateError("Invalid State!");
    }

    for (bool boolean in completedProcesses) {
      run |= !boolean;
    }
  } while (run);
}

Iterable<ProcessSpan> priority(List<Process> processes) sync* {
  List<bool> completedProcesses = List<bool>.filled(processes.length, false);
  List<(int index, Process process)> queue = <(int index, Process process)>[];

  CpuState state = CpuState.waiting;

  (int index, Process process, int start, int span)? currentRunning;
  int currentTime = 0;

  bool run = true;
  do {
    run = false;

    for (int i = 0; i < processes.length; ++i) {
      Process process = processes[i];
      if (!completedProcesses[i] && process.arrivalTime == currentTime) {
        /// We have to add.
        if (queue.isEmpty) {
          queue.add((i, process));
          continue;
        }

        bool hasAdded = false;
        // [1, 3], 0
        //     ^   False
        // [1, 3], 0
        //  ^      False
        //
        for (int j = queue.length - 1; j >= 0; --j) {
          Process left = queue[j].$2;
          Process right = process;

          if (left.priority! <= right.priority!) {
            hasAdded = true;
            queue.insert(j + 1, (i, process));
            break;
          }
        }

        if (!hasAdded) {
          queue.insert(0, (i, process));
        }
      }
    }

    switch ((state, currentRunning)) {
      case (CpuState.waiting, null):
        if (queue.isNotEmpty) {
          var (int index, Process process) = queue.removeAt(0);
          currentRunning = (index, process, currentTime, 1);
          state = CpuState.running;
        }
        currentTime++;
      case (CpuState.running, (int index, Process process, int start, int span)):
        if (span == process.burstTime) {
          /// The process has completed.
          completedProcesses[index] = true;
          yield (start: start, end: currentTime, id: process.id);

          /// Reset the state machine.
          currentRunning = null;
          state = CpuState.waiting;
        } else {
          currentRunning = (index, process, start, span + 1);

          currentTime++;
        }
      case _:
        throw StateError("Invalid State!");
    }

    run |= completedProcesses.any((bool element) => !element);
    run &= currentTime < 30;
  } while (run);
}

void printGanttChart(Iterable<ProcessSpan> ganttChart, [int length = 60]) {
  List<ProcessSpan> laidGanttChart = ganttChart.toList();
  int totalSpan = laidGanttChart.last.end - laidGanttChart.first.start;
  List<int> spanPrintSizes = laidGanttChart //
      .map((ProcessSpan span) => (span.end - span.start) / totalSpan)
      .map((double ratio) => (ratio * length).floor())
      .toList();

  StringBuffer firstLine = StringBuffer();
  for (int size in spanPrintSizes) {
    firstLine.write("+${"-" * (size - 1)}");
  }
  firstLine.write("+");
  print(firstLine);

  StringBuffer secondLine = StringBuffer();
  for (int i = 0; i < laidGanttChart.length; ++i) {
    ProcessSpan span = laidGanttChart.elementAt(i);
    int size = spanPrintSizes[i];
    secondLine
      ..write("|")
      ..write(span.id.padLeft((size / 2).round()).padRight(size - 1));
  }
  secondLine.write("|");
  print(secondLine);

  StringBuffer thirdLine = StringBuffer();
  for (int size in spanPrintSizes) {
    thirdLine.write("+${"-" * (size - 1)}");
  }
  thirdLine.write("+");
  print(firstLine);

  StringBuffer fourthLine = StringBuffer();
  fourthLine.write(laidGanttChart.first.start);
  for (var (int i, ProcessSpan span) in laidGanttChart.indexed) {
    int size = spanPrintSizes[i];
    fourthLine.write("${span.end}".padLeft(size));
  }
  print(fourthLine);
}

void main() {
  List<Process> processes = <Process>[
    (id: "P1", burstTime: 6, arrivalTime: 2, priority: 3),
    (id: "P2", burstTime: 2, arrivalTime: 5, priority: 1),
    (id: "P3", burstTime: 8, arrivalTime: 1, priority: 0),
    (id: "P4", burstTime: 3, arrivalTime: 1, priority: 2),
    (id: "P5", burstTime: 4, arrivalTime: 4, priority: 1),
  ];

  print("Priority:");
  printGanttChart(priority(processes));
}
