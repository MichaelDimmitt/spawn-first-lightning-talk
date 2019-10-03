defmodule SpawnExample do
  def start() do
    send self(), {:hello, "hello world"}
    receive do
      {:hello, msg} -> IO.inspect(msg)
      {:world, _msg} -> IO.inspect("won't match")
    end
    pid = spawn(fn -> loop() end)
    sequential_stop = spawn(fn -> stateful_loop('', 0) end)

    # sequentialStart(pid);
    concurrentStart(pid);
    concurrentPromise(sequential_stop)
    parallel(sequential_stop)
  end

  def loop() do
    receive do
      message -> IO.puts "#{message}";
      loop();
    end
  end

  def stateful_loop(state, inc) do
    receive do
      inc=2 -> IO.inspect('we did it!', state);
      inc=1 -> stateful_loop(state, inc+1);
      inc=0 -> stateful_loop(state<>state, inc+1);

    end
  end


  def resolveAfter2Seconds(pid) do
    Process.sleep(2000);
    IO.inspect("slow promise is done");
    send pid, "slow"
  end

  def resolveAfter1Second(pid) do
    Process.sleep(1000);

    IO.inspect("fast promise is done");
    send pid, "fast"
  end

  def sequentialStart(pid) do
    ## 1. Execution gets here almost instantly
    IO.inspect("==SEQUENTIAL START==");

    ## 2. this runs 2 seconds after 1.
    resolveAfter2Seconds(pid);

    ## 3. this runs 3 seconds after 1.
    resolveAfter1Second(pid);
  end

  def concurrentStart(pid) do
    IO.inspect('==CONCURRENT START with await==');
    Process.sleep(1000);
    spawn(fn -> resolveAfter2Seconds(pid) end); ## starts timer immediately
    spawn(fn -> resolveAfter1Second(pid)  end); ## starts timer immediately
    Process.sleep(3000);
  end

  def concurrentPromise(pid) do
    IO.inspect('==CONCURRENT START with Promise.all==');
    Process.sleep(1000);
    spawn(fn -> resolveAfter2Seconds(pid);
      spawn(fn -> resolveAfter1Second(pid)  end);
    end);

    Process.sleep(4000);
  end
  def parallel(pid) do
    IO.inspect('==PARALLEL with await Promise.all==');

    ## Start 2 "jobs" in parallel and wait for both of them to complete
    Process.sleep(1000);
    spawn(fn -> resolveAfter2Seconds(pid) end); ## starts timer immediately
    spawn(fn -> resolveAfter1Second(pid)  end); ## starts timer immediately
    Process.sleep(4000);
  end

end
SpawnExample.start()
