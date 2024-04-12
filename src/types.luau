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

export type DiffEntry<T> = {
    k: any,
    t: "+" | "-" | "~",
    v: T | { a: T, b: T }, -- latter for t=="~"
}

export type TableDiff = {
    diff: { [number]: DiffEntry<any> },
    sub: { [any]: TableDiff }?,
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
