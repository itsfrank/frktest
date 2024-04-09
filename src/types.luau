type Location = {
    file: string,
    line: string,
}

export type Failure = {
    location: Location,
    message: string,
    user_msg: string?,
    complex_info: {
        type: string,
        data: any,
    }?,
}

export type ArrayDiff<T> = {
    {
        i: number,
        v: T,
        t: "+" | "-",
    }
}

export type TestError = {
    location: Location,
    strace: string,
    error: any,
}

export type Test = {
    name: string,
    fn: () -> nil,
    failed: boolean,
}

export type Suite = {
    name: string,
    fn: () -> nil,
    tests: { Test },
}

export type ExecCounts = {
    suites: number,
    tests: number,
}

export type ExecResult = {
    ran: number,
    passed: number,
    failed: number,
}

return {}
